int main(){
	int a;
	int b;
	int x;

	a = 4;
	b = 5;
	x = -3;
/*
	if (a == b || x < 5) {
		write_string("or check\n");
	}

	if (a == b && x < 5) {
		write_string("and check\n");
	}

	if (a < b) {
		write_string("a < b\n");
	} else if (a > b) {
		write_string("a > b\n");
	} else {
		write_string("a == b\n");
	}
*/
	if (a < b) {
		/*write_string("a < b\n");*/
		if (x > 0) {
			write_string("x > 0\n");
			/*
			if (x < 5) {
				write_string("0 < x < 5\n");
			}
			else {
				write_string("x >= 5\n");
			}
			*/
		} else if (x > -10) {
			/*
			write_string("-10 < x < 0\n");
			if (x == -5) {
				write_string("x == -5\n");
			}
			*/
			write_string("x > -10\n");
		}
		else {
			write_string("x <= -10\n");
		}
	}
	/*
	else {
		write_string("a >= b\n");
	}
	*/
}