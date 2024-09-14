type DestroyLike<T> = {
	destroy: (self: unknown, ...args: Array<unknown>) => unknown;
};

/**
 * Checks whether the value is an instance of {@link Janitor} class.
 */
export function isJanitor(value: unknown): boolean;

export { isJanitor as is };

interface Janitor<TKey> {
	/**
	 * Adds `callback` to the top of the cleanup stack.
	 */
	addFunction(callback: Callback, key?: TKey): Janitor<TKey>;

	/**
	 * Alias for {@link Janitor.addFunction} method.
	 */
	addFn: Janitor<TKey>["addFunction"];

	add<TInput extends object>(
		object: TInput,
		methodName: keyof TInput,
		key?: TKey,
	): Janitor<TKey>;

	addSelf<TInput extends DestroyLike<unknown>>(
		destroyLike: TInput,
		key?: TKey,
	): Janitor<TKey>;

	/**
	 * Shorthand for the add(connection, "Disconnect") call.
	 */
	addConnection(connection: RBXScriptConnection, key?: TKey): Janitor<TKey>;

	/**
	 * Shorthand for the add(promise, "cancel") call.
	 */
	addPromise(promise: PromiseLike<unknown>, key?: TKey): Janitor<TKey>;

	/**
	 * Shorthand for the add(instance, "Destroy") call.
	 */
	addInstance(instance: Instance, key?: TKey): Janitor<TKey>;

	/**
	 * Utilizes {@link task.cancel} function.
	 */
	addTask(task: thread, key?: TKey): Janitor<TKey>;

	/**
	 * Utilizies {@link coroutine.close} function.
	 */
	addCoroutine(co: thread, key?: TKey): Janitor<TKey>;

	addCleanupRace(
		setup: (winRace: Callback) => Callback,
		onCleanup: Callback,
		key?: TKey,
	): Janitor<TKey>;

	isKeyAttached(key: TKey): boolean;
	keysAttached(...keys: ReadonlyArray<TKey>): boolean;

	/**
	 * Calls the cleanup function and removes it from the stack.
	 * @param key A key to which cleanup function is bound.
	 */
	clean(key: TKey): Janitor<TKey>;

	/**
	 * Removes the cleanup function associated with a provided key from the stack.
	 * @param key A key to which cleanup function is bound.
	 */
	remove(keys: TKey): Janitor<TKey>;

	cleanup(): Janitor<TKey>;

	/**
	 * Destroys the Janitor.
	 *
	 * Further method calls will throw an error.
	 */
	destroy(): void;

	/**
	 * Alias for {@link Janitor.destroy} method.
	 */
	(): Janitor<TKey>["destroy"];
}

interface JanitorConstructor<TKey = unknown> {
	new <TKey = unknown>(): Janitor<TKey>;
}

export declare const Janitor: JanitorConstructor;
