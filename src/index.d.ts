type Proc = () => void;

export class Janitor<Key> {
    constructor();

    addFn(fn: Proc, key?: Key): void;

    /**
     *
     * @param key vairant
     */
    addFunction(fn: Proc, key?: Key): void;

    add<Object, MethodName extends keyof Object, Key>(
        object: Object,
        methodName: MethodName,
        key?: Key
    ): void;

    addSelf(janitor: Janitor<unknown>, key?: Key): void;

    /**
     * Shorthand for the add(connection, "Disconnect") call.
     */
    addConnection(connection: RBXScriptConnection, key?: Key): void;

    /**
     * Shorthand for the add(instance, "Destroy") call.
     */
    addInstance(instance: Instance, key?: Key): void;

    addRace(setup: (winRace: Proc) => Proc, onCleanup: Proc, key?: Key): Key;

    isKeyAttached(key: Key): boolean;

    /**
     * Calls the cleanup function and removes it from the stack.
     * @param key A key to which cleanup function is bound.
     */
    clean(key: Key): void;

    /**
     * Removes the cleanup function associated with a provided key from the stack.
     * @param key A key to which cleanup function is bound.
     */
    remove(key: Key): void;

    cleanup(): void;

    destroy(): void;
}

export declare function is(value: unknown): boolean;
