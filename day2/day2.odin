package main;

import "core:bufio";
import "core:fmt";
import "core:os";
import "core:strings";
import "core:strconv";
import "core:mem";

BUFFER_SIZE :: 2048;

main::proc() {
	track: mem.Tracking_Allocator;
	mem.tracking_allocator_init(&track, context.allocator);
	defer mem.tracking_allocator_destroy(&track);
	context.allocator = mem.tracking_allocator(&track)

	_main()

	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}

	for bad_free in track.bad_free_array{
		fmt.printf("%v leaked %v bytes\n", bad_free.location, bad_free.memory)
	}
}


_main :: proc ()  {
	path:= "day2/data/day2.test";
	fh, ferr := os.open(path);
	if ferr != 0 {
		fmt.panicf("Unable to open file %s", path);
	}
	defer os.close(fh);
	reader: bufio.Reader;
	buffer: [BUFFER_SIZE]byte;

	bufio.reader_init_with_buf(&reader, os.stream_from_handle(fh), buffer[:]);
	defer bufio.reader_destroy(&reader);

	line, err := bufio.reader_read_string(&reader, '\n')
	if err != nil {
		fmt.panicf("Unable to read line");
	}
	defer delete(line);
	prog: [BUFFER_SIZE]byte;
	index := 0;
	offset := 0;
	for r, i in line {
		if r == ',' {
			prog[index] = u8(line[offset:i])
			offset = i + 1;
			index += 1
		}
	}
	fmt.println(prog);

}

// Format of the Intcode
// OPCODE, Input, Input, Output
// OPCODES:
// 1: Add
// 2: Multiply

compute :: proc( prog: []u8) {
	
	line_size := 4;
	for offset := 0; offset < len(prog); offset += line_size {
		line := prog[offset:][:line_size];
		opcode := line[0]
		a := line[1]
		b := line[2]
		out := line[3]
		switch opcode {
			case 1:
				prog[out] = prog[a] + prog[b]
			case 2:
				prog[out] = prog[a] * prog[b]
			case:
				break
		}
	}
}



