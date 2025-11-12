//Figure 5.36: Counter Class

Counter {
	var <>max_count, <>current_count = 1;
	*new {
		|max_count = 10|
		^super.new.max_count_(max_count)
	}
	count1 {
		if (current_count >= max_count) {
			this.changed(\max_reached)
		}{
			current_count = current_count + 1;
			this.changed(\count, current_count);
		}
	}
	reset {
		current_count = 1;
		this.changed(\reset);
	}
}