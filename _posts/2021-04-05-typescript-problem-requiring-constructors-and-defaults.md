---
title: TypeScript problem with requiring constructors and defaults
date: 2021-04-05 22:41:25 +0800
tags: typescript
licence: Copyright © 2021 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# The Question

I ran into an interesting TypeScript question.

Here's the situation: we want to create new objects in our generic class, so we have this definition:

```typescript
export class Handbag<T> {
  constructor(private type: new() => T) {
    let handle = new type();
  }
}
```
Then users of our class have to provide the class in their constructor:

```typescript
export class MyBag extends Handbag<Leather> {
  constructor() {
    super(Leather);
  }
}
```

Now for the question: is there a way to provide a default of `Object` for the parameter? That is, if the user omits supplying the parameter, the parameter should default to the `Object`, which we can do `new` on, ie. `new Object()`. The code below is what we have in mind, but it doesn't work:

```typescript
export class Handbag<T> {
  constructor(private type: (new() => T) = Object) {
    let handle = new type();
  }
}
```

Making the parameter optional and having an if/conditional works though:

```typescript
export class Handbag<T> {
  constructor(private type?: (new() => T) = Object) {
    let handle = new (type || Object)();
  }
}
```

Why doesn't having a default in the parameters work?

# An Explanation

If we "unpack" the body of the constructor, `handle` actually gets inferred a type of `T`. That is, if we were to be explicit with our types, the code would read:

```typescript
export class Handbag<T> {
  constructor(private type: (new() => T) = Object) {
    // previous:
    // let handle = new type();
    let handle: T = new type();
  }
}
```

Now we see why you can't supply `Object` as a default - because `new Object` doesn't give you something of the type `T`.

Indeed, in the solution we saw working with `let handle = new (type || Object)()`, the variable `handle` gets inferred a type of `Object`!

So, we'd have a couple of options, depending on whether we need `handle` to have a type `T`.

If so, then mark the parameter as optional by suffixing it with `?` and wrap the construction in a if/conditional:

```typescript
export class Handbag<T> {
  constructor(private type?: new() => T) {
    if (type) {
      let handle: T = new type();
    } else {
      //...
    }
  }
}
```

If `handle` having a type `T` is not important, then this would work:

```typescript
export class Handbag<T> {
  constructor(private type?: new() => any = Object) {
    let handle = new type();   // inferred as :any
  }
}
```

But I doubt you would want this, because that was the whole point of the generic `<T>` (unless there were other constraints on it).

# Learnings

I learnt a couple of things while looking into this:

- #TIL TypeScript gives you the ability to specify something has a constructor, eg.

    ```typescript
    interface HasConstructor<T> {
      new (): T;
    }
    ```

- The interesting thing is, you can't really define a type, and at the same time, say `implements HasConstructor<...>`, because you run into a kind of a circular situation where you are defining your type (say, `X`) *and* you'd want to use it at the same time (as the generic parameter to `implements HasConstructor<X>`):

    ```typescript
    class Apples // ok, you want to define Apples...
        implements HasConstructor<     // ok, you want to say it has a constructor
            Apples       // 💥 doesn't work - reference-before-defined
        > {
      constructor() {
          console.log("Apples constructed");
      }
    }
    ```

- BUT - you don't have to say `implements HasConstructor<...>` for TypeScript to recognize that `Apples` satifies `HasConstructor<T>`, because of structural typing [^structural-typing] as opposed to nominal (using names) typing.

    ```typescript
    class Apples {
      constructor() {
          console.log("Apples constructed");
      }
    }

    class WantsConstructor<T> {
        constructor(canBeConstructed: HasConstructor<T>) {
            const thing: T = new canBeConstructed();
        }
    }

    new WantsConstructor(Apples); // compiles OK
    ```

    While this works, as the author of `Apples`, with the absence of `implements ...`, you do lose some of documenting that it provides; it is less obvious to subsequent readers of `Apples` that you, the author, had intended `Apples` to implement a certain interface.

- BUT - how does TypeScript do it, for, say `Object`? How did it declare the type Object, specify that the constructor returned said type? Wouldn't it run into a similar situation of a circular/reference-before-defined that we mentioned above? I'll just link to [TypeScript's type definition for `Object`][lib-types] and look into this another day. :)

[^structural-typing]: <https://www.typescriptlang.org/docs/handbook/type-compatibility.html>
[lib-types]: <https://github.com/microsoft/TypeScript/blob/master/lib/lib.es5.d.ts>

