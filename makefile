OBJ = main.o parabola.o
BIN = prog.exe
CFLAGS = -m32
CC = g++

$(BIN): $(OBJ)
	$(CC) $(OBJ) $(CFLAGS) -lsfml-graphics -lsfml-window -lsfml-system -o $(BIN) 
main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp -o main.o 
parabola.o: parabola.s
	nasm -f elf parabola.s
clean:
	del $(BIN) 
	del $(OBJ)
