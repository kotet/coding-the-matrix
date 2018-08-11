/*
URL:
Downloading...
Error. Fallback: http://resources.codingthematrix.com/stories_small.txt

Downloading...

Indexing...

Action[or/and]: or
===OR search===
Query: my
[4, 5, 13, 22, 24, 25, 34, 35, 40]

Action[or/and]: or
===OR search===
Query: suicide
[10]

Action[or/and]: or
===OR search===
Query: my suicide
[4, 5, 10, 13, 22, 24, 25, 34, 35, 40]

Action[or/and]: and
===AND search===
Query: my suicide
[]

Action[or/and]:
Exitting...
*/

import std.stdio : write, writeln, readln;
import std.algorithm : uniq, sort, isSorted, map, reduce;
import std.range : array, front, popFront;
import std.string : split, chomp;
import std.net.curl : get, CurlException;
import std.conv : to;

void main()
{
	"URL: ".write;
	string url = readln.chomp;
	"Downloading...".writeln;
	string txt;
	try
	{
		txt = get(url).to!string;
	}
	catch (CurlException)
	{
		immutable fallback = "http://resources.codingthematrix.com/stories_small.txt";
		("Error. Fallback: " ~ fallback).writeln;
		"\nDownloading...".writeln;
		txt = get(fallback).to!string;
	}
	"\nIndexing...".writeln;
	string[] strlist = txt.split('\n');
	size_t[][string] inverse_index = strlist.makeInverseIndex;
	while (true)
	{
		"\nAction[or/and]: ".write;
		string action = readln.chomp;
		if (action == "or")
		{
			"===OR search===".writeln;
			"Query: ".write;
			inverse_index.orSearch(readln.chomp.split).writeln;

		}
		else if (action == "and")
		{
			"===AND search===".writeln;
			"Query: ".write;
			inverse_index.andSearch(readln.chomp.split).writeln;
		}
		else
		{
			"Exitting...".writeln;
			return;
		}
	}
}

size_t[][string] makeInverseIndex(string[] strlist)
{
	size_t[][string] aa;
	foreach (size_t i, string doc; strlist)
		foreach (string word; doc.split())
		{
			if (word in aa)
			{
				aa[word] ~= i;
			}
			else
			{
				aa[word] = [i];
			}
		}
	foreach (key, ref value; aa)
		value = value.uniq.array;
	return aa;
}

size_t[] orSearch(size_t[][string] inverse_index, string[] query)
{
	size_t[] result;
	foreach (string q; query)
		if (q in inverse_index)
			result ~= inverse_index[q];
	return result.sort.uniq.array;
}

size_t[] andSearch(size_t[][string] inverse_index, string[] query)
{
	size_t[] result;
	return query.map!(q => inverse_index[q])
		.reduce!(and)
		.array;
}

size_t[] and(size_t[] a, size_t[] b)
{
	size_t[] result;
	assert(a.isSorted && b.isSorted);
	while (0 < a.length)
	{
		while (b.front < a.front)
			if (b.length == 1)
			{
				return result;
			}
			else
			{
				b.popFront();
			}
		if (a.front == b.front)
		{
			result ~= a.front;
		}
		a.popFront();
	}
	return result;
}
