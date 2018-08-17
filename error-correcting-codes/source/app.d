/*
Original text:	I'm trying to free your mind, Neo. But I can only show you the door. You're the one that has to walk through it.

Enter error rate (0.0-1.0): 0.01
Error + Text:	I'm trying`to free youv mmnd, NEo.�But I cal onLy show you tie door.$You'be tje one that(has to wal� throufh it.
Corrected Text:	I'm trying to free your mind, Neo. But I can only show you the door. You're the one that has to walk through it.
Correction succeeded!
==================================================================
Enter error rate (0.0-1.0): 0.01
Error + Text:	I'm trying to`free �our mind, Neo. But I can only show q�u �he door. You're thd one that has to walk through it.
Corrected Text:	I'm trying to free your mind, Neo. But I can only show you the door. You're the one that has to walk through it.
Correction succeeded!
==================================================================
Enter error rate (0.0-1.0): 0.01
Error + Text:	I'm trying to &ree 9our mifd, Neo. But"I can only show you the door. You'r} the one that has to walk through it.
Corrected Text:	I'm trying to free your mind, Neo. But I can only show you the door. You're the one that has to walk through it.
Correction succeeded!
==================================================================
Enter error rate (0.0-1.0): 0.01
Error + Text:	O'o trying!to free your mind,0Neo. Bud I can only sho� youthe door. Xou're the ong that has to walk �hzough mt.
Corrected Text:	G'm trying to free your mind, Neo. But I can only show you the door. You're the one that has to walk through it.
Correction failed.
==================================================================
Enter error rate (0.0-1.0): 0.01
Error + Text:	I'm tbying tk free your mhNd, Neo. But I can onl{ whow you the door. You're the one �hat h`s to walk throug� mt.
Corrected Text:	I'm trying to free your mind, Neo. But I can only show you the door. You're the one that has to walk through it.
Correction succeeded!
==================================================================
Enter error rate (0.0-1.0): ^C
*/

alias Matrix(ubyte R, ubyte C) = ubyte[C][R];

static immutable G = () {
	Matrix!(7, 4) G;
	G[0] = [1, 0, 1, 1];
	G[1] = [1, 1, 0, 1];
	G[2] = [0, 0, 0, 1];
	G[3] = [1, 1, 1, 0];
	G[4] = [0, 0, 1, 0];
	G[5] = [0, 1, 0, 0];
	G[6] = [1, 0, 0, 0];
	return G;
}();

static immutable H = () {
	Matrix!(3, 7) H;
	H[0] = [0, 0, 0, 1, 1, 1, 1];
	H[1] = [0, 1, 1, 0, 0, 1, 1];
	H[2] = [1, 0, 1, 0, 1, 0, 1];
	return H;
}();

static immutable D = () {
	Matrix!(4, 7) D;
	D[0][6] = 1;
	D[1][5] = 1;
	D[2][4] = 1;
	D[3][2] = 1;
	return D;
}();

void main()
{
	import std.stdio;

	enum s = "I'm trying to free your mind, Neo."
			~ " But I can only show you the door. You're the one that has to walk through it.";

	writeln("Original text:\t", s, "\n");

	auto m = s.str2mat();
	auto c = G.mul(m);

	while (true)
	{
		import std.string : chomp;
		import std.conv : to;

		"Enter error rate (0.0-1.0): ".write;
		double error_rate = readln.chomp.to!double;

		auto e = noise!(typeof(c))(error_rate);
		auto ctilde = c.add(e);

		"Error + Text:\t".write;
		D.mul(ctilde).mat2str.writeln;

		auto corrected = D.mul(ctilde.correct).mat2str;

		"Corrected Text:\t".write;
		corrected.writeln;

		writeln("Correction ", (s == corrected) ? "succeeded!" : "failed.");
		"==================================================================".writeln;
	}
}

string str(size_t r, size_t c)(ubyte[c][r] mat)
{
	import std.algorithm : map;
	import std.array : join;
	import std.conv : to;

	return mat.to!(string[][])
		.map!(r => r.join(' '))
		.join('\n');
}

auto mul(size_t rr, size_t rc, size_t lr, size_t lc,)(ubyte[lc][lr] lhs, ubyte[rc][rr] rhs)
{
	assert(lc == rr);

	ubyte[rc][lr] result;
	foreach (i, r; lhs)
	{
		ubyte[rc][lc] tmp;
		foreach (j, n; r)
			tmp[j][] = rhs[j][] & n;
		foreach (t; tmp)
			result[i][] ^= t[];
	}
	return result;
}

auto add(size_t r, size_t c)(ubyte[c][r] a, ubyte[c][r] b)
{
	ubyte[c][r] result;
	foreach (i; 0 .. r)
		result[i][] = a[i][] ^ b[i][];
	return result;
}

auto transpose(size_t r, size_t c)(ubyte[c][r] mat)
{
	ubyte[r][c] result;
	foreach (i; 0 .. r)
		foreach (j; 0 .. c)
			result[j][i] = mat[i][j];
	return result;
}

auto findError(ubyte[3] syndrome)
{
	Matrix!(1, 7) result;
	foreach (i, r; H.transpose)
		if (syndrome == r)
		{
			result[0][i] = 1;
			return result;
		}
	return result;
}

auto findErrorMatrix(size_t c)(ubyte[c][3] mat)
{
	Matrix!(c, 7) result;
	foreach (i, r; mat.transpose)
	{
		result[i][] = findError(r)[0];
	}
	return result.transpose;
}

auto str2mat(size_t len)(char[len] str)
{
	Matrix!(4, len * 2) result;
	ubyte[len] arr = cast(ubyte[len]) str;
	foreach (i, c; arr)
		foreach (j; 0 .. 2)
			foreach (k; 0 .. 4)
			{
				result[k][i * 2 + j] = (c & (1 << ((j * 4) + k))) >> ((j * 4) + k);
			}

	return result;
}

auto mat2str(size_t c)(ubyte[c][4] mat)
{
	ubyte[c / 2] result;
	foreach (i, r; mat.transpose)
		foreach (j; 0 .. 4)
		{
			result[i / 2] |= r[j] << ((i % 2) * 4) + j;
		}
	return cast(char[c / 2]) result;
}

T noise(T)(double error_rate)
{
	import std.random : dice;

	assert(0 <= error_rate && error_rate <= 1);

	T result;
	foreach (ref r; result)
		foreach (ref item; r)
			item = cast(ubyte) dice(1 - error_rate, error_rate);
	return result;
}

auto correct(size_t c)(ubyte[c][7] ce)
{
	auto syndrome = H.mul(ce);
	auto e = syndrome.findErrorMatrix();
	return ce.add(e);
}
