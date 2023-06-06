package main;

import "core:bufio";
import "core:fmt";
import "core:os";
import "core:strings";
import "core:strconv"


main :: proc ()  {
	path:= "day1/data/day1.test";
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
	for {
		line, err := bufio.reader_read_string(&reader, '\n', context.allocator)
		if err != nil {
			break
		}
		defer delete(line, context.allocator)
		line = strings.trim_right(line, "\r");

		num, perr := strconv.parse_u64(line);

		if perr {
			fmt.panicf("Unable to pares value '%s' as a number");
		}
		delta := total_fuel(int(num));
		fmt.println(delta);
		sum += delta;
	}
	fmt.println("The answer is: ", sum);

}

total_fuel :: proc (mass: int) -> (u64) {

	fuel := 0;
	delta:int = mass / 3 - 2;
	for delta > 0 {
		fuel += delta;
		delta = delta / 3 - 2;
	}

	return u64(fuel);

}

