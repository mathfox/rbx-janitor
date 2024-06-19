export type DestroyLike<T> = {
	destroy: (self: T, ...args: Array<unknown>) => unknown;
};

export declare interface Janitor<Key = unknown> {
	/**
	 * Adds `callback` to the top of the cleanup stack.
	 */
	addFunction(callback: Callback, key?: Key): Janitor<Key>;

	/**
	 * Alias for {@link Janitor.addFunction} method.
	 */
	addFn: Janitor["addFunction"];

	add<Object, MethodName extends keyof Object>(
		object: Object,
		methodName: MethodName,
		key?: Key,
	): Janitor<Key>;

	addSelf<T extends {}>(destroyLike: T, key?: Key): Janitor<Key>;

	/**
	 * Shorthand for the add(connection, "Disconnect") call.
	 */
	addConnection(connection: RBXScriptConnection, key?: Key): Janitor<Key>;

	/**
	 * Shorthand for the add(promise, "cancel") call.
	 */
	addPromise<T>(promise: Promise<T>, key?: Key): Janitor<Key>;

	/**
	 * Shorthand for the add(instance, "Destroy") call.
	 */
	addInstance(instance: Instance, key?: Key): Janitor<Key>;

	/**
	 * Utilizes {@link task.cancel} function.
	 */
	addTask(task: thread, key?: Key): Janitor<Key>;

	/**
	 * Utilizies {@link coroutine.close} function.
	 */
	addCoroutine(co: thread, key?: Key): Janitor<Key>;

	addCleanupRace(
		setup: (winRace: Callback) => Callback,
		onCleanup: Callback,
		key?: Key,
	): Janitor<Key>;

	isKeyAttached(key: Key): boolean;
	keysAttached(...keys: Array<Key>): boolean;

	/**
	 * Calls the cleanup function and removes it from the stack.
	 * @param key A key to which cleanup function is bound.
	 */
	clean(key: Key): Janitor<Key>;

	/**
	 * Removes the cleanup function associated with a provided key from the stack.
	 * @param key A key to which cleanup function is bound.
	 */
	remove(keys: Key): Janitor<Key>;

	cleanup(): Janitor<Key>;

	/**
	 * Destroys the Janitor.
	 *
	 * Further method calls will throw an error.
	 */
	destroy(): void;

	/**
	 * Alias for {@link Janitor.destroy} method.
	 */
	(): Janitor["destroy"];
}

export const Janitor: new <Key = unknown>() => Janitor<Key>;

/**
 * @deprecated
 */
export const is: typeof isJanitor;

/**
 * Checks whether the value is an instance of {@link Janitor} class.
 */
export function isJanitor(value: unknown): boolean;
