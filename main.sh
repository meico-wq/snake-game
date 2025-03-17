#!/bin/bash

# Snake game written in pure Bash 5.2.37

# Coded by ./meicookies

GREEN="\e[92m"
RESET="\e[0m"

ROWS=10
COLS=20
SNAKE_CHAR="${GREEN}O${RESET}"
FOOD_CHAR="${GREEN}X${RESET}"
SPECIAL_FOOD_CHAR="${GREEN}*${RESET}"
WALL_CHAR="${GREEN}#${RESET}"
DELAY=0.2
SCORE=0
HIGHSCORE_FILE=".snake_highscore"

[[ -f "$HIGHSCORE_FILE" ]] && HIGHSCORE=$(cat "$HIGHSCORE_FILE") || HIGHSCORE=0

menu() {
    clear
    echo -e "${GREEN}=== SNAKE GAME ===${RESET}"
    echo -e "${GREEN}High Score: $HIGHSCORE${RESET}"
    echo -e "${GREEN}[1] Mulai Game${RESET}"
    echo -e "${GREEN}[2] Keluar${RESET}"
    read -n1 -p "Pilih opsi: " choice
    [[ $choice == "1" ]] && start_game || exit
}

start_game() {
    snake_x=(5)
    snake_y=(5)
    dir_x=1
    dir_y=0
    food_x=$((RANDOM % (COLS - 2) + 1))
    food_y=$((RANDOM % (ROWS - 2) + 1))
    special_food_x=-1
    special_food_y=-1
    running=1
    SCORE=0

    while [[ $running -eq 1 ]]; do
        draw_board
        read_input
        update_snake
    done

    [[ $SCORE -gt $HIGHSCORE ]] && echo "$SCORE" > "$HIGHSCORE_FILE" && echo -e "${GREEN}New High Score: $SCORE!${RESET}" || echo -e "${GREEN}Game Over! Final Score: $SCORE${RESET}"
    read -p "Tekan Enter untuk kembali ke menu..."
    menu
}

draw_board() {
    clear
    echo -e "${GREEN}Score: $SCORE | High Score: $HIGHSCORE${RESET}"
    declare -A board
    for ((y=0; y<ROWS; y++)); do
        for ((x=0; x<COLS; x++)); do
            [[ $y -eq 0 || $y -eq $((ROWS - 1)) || $x -eq 0 || $x -eq $((COLS - 1)) ]] && board["$x,$y"]="$WALL_CHAR"
        done
    done
    board["$food_x,$food_y"]="$FOOD_CHAR"
    [[ $special_food_x -ge 0 && $special_food_y -ge 0 ]] && board["$special_food_x,$special_food_y"]="$SPECIAL_FOOD_CHAR"
    for ((i=0; i<${#snake_x[@]}; i++)); do
        board["${snake_x[$i]},${snake_y[$i]}"]="$SNAKE_CHAR"
    done
    for ((y=0; y<ROWS; y++)); do
        for ((x=0; x<COLS; x++)); do
            echo -en "${board[$x,$y]:- }"
        done
        echo
    done
}

read_input() {
    read -t "$DELAY" -n1 key
    [[ -n "$key" ]] && case "$key" in
        w) [[ $dir_y -eq 0 ]] && dir_x=0 && dir_y=-1 ;;
        s) [[ $dir_y -eq 0 ]] && dir_x=0 && dir_y=1  ;;
        a) [[ $dir_x -eq 0 ]] && dir_x=-1 && dir_y=0 ;;
        d) [[ $dir_x -eq 0 ]] && dir_x=1 && dir_y=0  ;;
    esac
}

update_snake() {
    new_x=$((snake_x[0] + dir_x))
    new_y=$((snake_y[0] + dir_y))
    [[ $new_x -eq 0 || $new_x -eq $((COLS - 1)) || $new_y -eq 0 || $new_y -eq $((ROWS - 1)) ]] && running=0 && return
    for ((i=0; i<${#snake_x[@]}; i++)); do
        [[ ${snake_x[$i]} -eq $new_x && ${snake_y[$i]} -eq $new_y ]] && running=0 && return
    done
    snake_x=("$new_x" "${snake_x[@]}")
    snake_y=("$new_y" "${snake_y[@]}")
    if [[ $new_x -eq $food_x && $new_y -eq $food_y ]]; then
        SCORE=$((SCORE + 10))
        food_x=$((RANDOM % (COLS - 2) + 1))
        food_y=$((RANDOM % (ROWS - 2) + 1))
        [[ $((RANDOM % 5)) -eq 0 ]] && special_food_x=$((RANDOM % (COLS - 2) + 1)) && special_food_y=$((RANDOM % (ROWS - 2) + 1))
    elif [[ $new_x -eq $special_food_x && $new_y -eq $special_food_y ]]; then
        SCORE=$((SCORE + 20))
        special_food_x=-1
        special_food_y=-1
    else
        snake_x=("${snake_x[@]:0:${#snake_x[@]}-1}")
        snake_y=("${snake_y[@]:0:${#snake_y[@]}-1}")
    fi
}

menu
