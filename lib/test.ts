const janitor = new Janitor()
	.addFn(() => {
		warn("third");
	})
	.addFn(() => {
		warn("second");
	})
	.addFn(() => {
		warn("first after connection was cleaned up");
	})
	.addConnection(
		game.DescendantAdded.Connect(() => {
			// some code related to
		})
	);
