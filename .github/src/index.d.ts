export type Janitor = JanitorImpl;

export type JanitorObject =
    | Instance
    | RBXScriptConnection
    | (() => void)
    | Record<string | number | symbol, unknown>;

interface JanitorImpl {
    __index: JanitorImpl;
    __tostring(): "Janitor";

    add(): void;
}

export declare function is(value: unknown): boolean;
