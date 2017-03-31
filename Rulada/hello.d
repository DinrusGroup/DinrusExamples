import std.io;

int main(char[][] args)
{
    writef("hello world\n");
    writef("args.length = %d\n", args.length);
    for (int i = 0; i < args.length; i++)
	writef("args[%d] = '%s'\n", i, cast(char *)args[i]);
    return 0;
}
