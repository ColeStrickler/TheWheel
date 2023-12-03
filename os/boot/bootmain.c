


// Remember that we must specifically tell the linker where we are going to be loading our code
void bootmain()
{
	char* video_memory = (char*)0xb8000;
	*video_memory++ = 'Z';
	*video_memory = (char)0x4;
}

