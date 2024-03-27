type Proc = () => void;

export class Janitor<Key = unknown> {
    constructor();

    addFn(fn: Proc, key?: Key): Janitor<Key>;

    addFunction(fn: Proc, key?: Key): Janitor<Key>;

    add<Object, MethodName extends keyof Object, Key>(
        object: Object,
        methodName: MethodName,
        key?: Key
    ): Janitor<Key>;

    addSelf<
        T extends {
            destroy: (self: T, ...[]) => unknown;
        }
    >(destroyLike: T, key?: Key): Janitor<Key>;

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

    addTask(task: thread, key?: Key): Janitor<Key>;
    addCoroutine(co: thread, key?: Key): Janitor<Key>;

    addCleanupRace(
        setup: (winRace: Proc) => Proc,
        onCleanup: Proc,
        key?: Key
    ): Janitor<Key>;

    isKeyAttached(key: Key): boolean;
    keysAttached(...keys: Key[]): boolean;

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

    destroy(): void;
}

export declare function is(value: unknown): boolean;
