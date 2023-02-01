#!/usr/bin/env bash
echo "Welcome to the True or False Game!"
curl --silent --output ID_card.txt http://127.0.0.1:8000/download/file.txt
$(curl --silent --cookie-jar cookie.txt --user "$(cut -d '"' -f 4 ID_card.txt | head -1):$(cut -d '"' -f 8 ID_card.txt | head -1)" http://127.0.0.1:8000/login)
compliments=( "Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!" )
while true; do
  echo "0. Exit"
  echo "1. Play a game"
  echo "2. Display scores"
  echo "3. Reset scores"
  echo "Enter an option:"

  read -r opt

  case "$opt" in
  0)
    echo "See you later!"
    break
    ;;
  1)
    echo "What is your name?"
    read -r username
    answersCount=0
    while true; do
      qa=$(curl --cookie cookie.txt http://127.0.0.1:8000/game)
      echo "$qa" | sed 's/.*"question": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/'
      echo "True or False?"
      read -r answer
      if [ $answer = $(echo "$qa" | sed 's/.*"answer": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/') ]; then
        ((answersCount=answersCount+1))
        idx=$((RANDOM % 5))
        echo "$compliments[$idx]"
      else
        echo "Wrong answer, sorry!"
        echo "$username you have $answersCount correct answer(s)."
        echo "Your score is $(($answersCount * 10)) points."
        echo "User: $username, Score: $(($answersCount * 10)), Date: $(date +"%Y-%m-%d")" >> scores.txt
        break
      fi
    done
    ;;
  2)
    if [ -s scores.txt ]; then
      echo "Player scores"
      cat scores.txt
    else
      echo "File not found or no scores in it!"
    fi
    ;;
  3)
    if [ -s scores.txt ]; then
      rm scores.txt
      echo "File deleted successfully!"
    else
      echo "File not found or no scores in it!"
    fi
    ;;
  *)
    echo "Invalid option!"
    ;;
  esac
done
