# Overview

A stack-based Janitor implementation written in Luau for the Roblox platform with a TypeScript support.

## Basic usage

```ts
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
			// some code
		})
	);

task.delay(1, () => {
    janitor.destroy()
    // or
    janitor.cleanup()
    // for further cleanup tasks
})
```
