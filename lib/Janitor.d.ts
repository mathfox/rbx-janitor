type Proc = () => void;

interface IJanitor<Key extends any> {
	addFunction(fn: Proc, key?: Key): IJanitor<Key>;

	add<Object, MethodName extends keyof Object, K extends Key>(
		object: Object,
		methodName: MethodName,
		key?: K
	): IJanitor<Key>;

	addSelf<
		T extends {
			destroy: (self: T, ...[]) => unknown;
		}
	>(
		destroyLike: T,
		key?: Key
	): IJanitor<Key>;

	/**
	 * Shorthand for the add(connection, "Disconnect") call.
	 */
	addConnection(connection: RBXScriptConnection, key?: Key): IJanitor<Key>;

	/**
	 * Shorthand for the add(promise, "cancel") call.
	 */
	addPromise<T>(promise: Promise<T>, key?: Key): IJanitor<Key>;

	/**
	 * Shorthand for the add(instance, "Destroy") call.
	 */
	addInstance(instance: Instance, key?: Key): IJanitor<Key>;

	addTask(task: thread, key?: Key): IJanitor<Key>;
	addCoroutine(co: thread, key?: Key): IJanitor<Key>;

	addCleanupRace(
		setup: (winRace: Proc) => Proc,
		onCleanup: Proc,
		key?: Key
	): IJanitor<Key>;

	isKeyAttached(key: Key): boolean;
	keysAttached(...keys: Key[]): boolean;

	/**
	 * Calls the cleanup function and removes it from the stack.
	 * @param key A key to which cleanup function is bound.
	 */
	clean(key: Key): IJanitor<Key>;

	/**
	 * Removes the cleanup function associated with a provided key from the stack.
	 * @param key A key to which cleanup function is bound.
	 */
	remove(keys: Key): IJanitor<Key>;

	cleanup(): IJanitor<Key>;

	/**
	 * Destroys the Janitor.
	 *
	 * Further method calls will throw an error.
	 */
	destroy(): void;
}

export declare const Janitor: new <Key extends any = any>() => IJanitor<Key> & {
	/**
	 * Alias for {@link IJanitor.destroy} method.
	 */
	(): IJanitor<Key>["destroy"];

	/**
	 * Alias for {@link IJanitor.addFunction} method.
	 */
	addFn: IJanitor<Key>["addFunction"];
};

/**
 * @deprecated
 */
export declare const is: typeof isJanitor;

/**
 * Checks whether the value is an instance of {@link Janitor} class.
 */
export declare function isJanitor(value: unknown): boolean;
