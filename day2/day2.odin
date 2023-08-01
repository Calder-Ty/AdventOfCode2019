package main;

import "core:bufio";
import "core:fmt";
import "core:os";
import "core:strings";
import "core:strconv";
import "core:mem";

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
	buffer: [2048]byte;

	bufio.reader_init_with_buf(&reader, {os.stream_from_handle(fh)}, buffer[:]);
	defer bufio.reader_destroy(&reader);


	sum :u64 = 0;
	line, err := bufio.reader_read_string(&reader, '\n')
	if err != nil {
		fmt.panicf("Unable to read line");
	}
	defer delete(line);
	line = strings.trim_right(line, "\n");

	prog := strings.split(line, ",");
	defer delete(prog);

	fmt.println(prog);

}

// Op-codes

total_fuel :: proc (mass: int) -> (u64) {

	fuel := 0;
	delta:int = mass / 3 - 2;
	for delta > 0 {
		fuel += delta;
		delta = delta / 3 - 2;
	}

	return u64(fuel);

}

