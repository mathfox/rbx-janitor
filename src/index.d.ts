type Proc = () => void;

export class Janitor<Key> {
    constructor();

    addFn(fn: Proc): void;

    add<Object, MethodName extends keyof Object, Key>(
        object: Object,
        methodName: MethodName,
        key?: Key
    ): void;

    addSelf(janitor: Janitor<unknown>, key?: Key): void;

    addConnection(connection: RBXScriptConnection, key?: Key): void;

    addInstance(instance: Instance, key?: Key): void;

    addRace(setup: (winRace: Proc) => Proc, onCleanup: Proc, key?: Key): Key;

    isKeyAttached(key: Key): boolean;

    clean(key: Key): void;

    remove(key: Key): void;

    cleanup(): void;

    destroy(): void;
}

export declare function is(value: unknown): boolean;
