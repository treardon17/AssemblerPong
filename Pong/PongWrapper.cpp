#include <conio.h>
#include <string>
using namespace std;

extern "C" void PongMain();

extern "C" void Concat(int P1, int P2) {
	printf("Player 1: %d Player 2: %d", P1, P2);
}

int main() {
	PongMain();
	return 0;
}