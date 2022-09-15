---
title: "#1: Don’t mutate React objects/arrays state. (Go Immer!)"
tags: react
licence: Copyright © 2022 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

<ul>
{% for entry in site.data.fifteen_days %}
  <li>
    {% if page.title != entry.name %}
    <a href="{{ entry.url }}">
      {{ entry.name }}
    </a>
    {% else %}
    {{ entry.name }}
    {% endif %}
  </li>
{% endfor %}
</ul>

If you've worked with React, you've probably come across the refrain *"don't mutate React state."* In this post, we'll take a look at why this is a bad idea, how you can avoid it, and how the Immer library can help.

## What is mutating React state?

Here's an example of what mutating React state might look like in a React component:

```react
const [anObject, setAnObject] = useState(...);
// ...
const onClick = () => {
  anObject.apples = "100";
  setAnObject(anObject);
};
//...
```

The React state variable, `anObject`, was mutated, to wit, its property `apples` had its value changed.

## Why not to mutate React state?

It can be challenging to identify a source for this refrain from the official React documentation. A good approximation from the class-based React style can be found buried in the React.Component API documentation:

> Never mutate this.state directly, as calling setState() afterwards may replace the mutation you made. Treat this.state as if it were immutable.
<figcaption>—<cite>React Docs, <a href="https://reactjs.org/docs/react-component.html#state">React.Component API reference, state property</a></cite></figcaption>
<br>

New work has been ongoing at [React Docs Beta](https://beta.reactjs.org), and while it is prominently caveated as a work-in-progress, it already looks very readable and detailed. React Docs beta state in no uncertain terms that for state variables created from the `useState()` hook, you should not mutate them:

> you should treat any JavaScript object that you put into state as read-only.
<figcaption>—<cite>React Docs Beta, <a href="https://beta.reactjs.org/learn/updating-objects-in-state#treat-state-as-read-only">Updating Objects in State</a></cite></figcaption>
<br>

To see why mutating React state can cause problems, the cited page above does an excellent job, starting out first with a buggy page with React code that goes against that recommendation, then pointing out the cause (mutating the state variable).

Without coming across as trying to one-up the React team, here's a Codesandbox that places side-by-side a React component that mutates React object and array state variables, and one that doesn't:

<iframe src="https://codesandbox.io/embed/tender-roman-d1ps8z?fontsize=14&hidenavigation=1&theme=dark"
style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;"
title="tender-roman-d1ps8z"
allow="accelerometer; ambient-light-sensor; camera; encrypted-media; geolocation; gyroscope; hid; microphone; midi; payment; usb; vr; xr-spatial-tracking"
sandbox="allow-forms allow-modals allow-popups allow-presentation allow-same-origin allow-scripts"
></iframe>

When clicking the 'Zero out mutably' or 'Grey out mutably' button, nothing seems to have changed visibly, when in fact, the JavaScript array/object was changed. On the other hand, when clicking the immutable counterparts, the changes show up on the page.

## How to not mutate React state?

How might we write the above if we were to avoid mutating the React state variable? Here's one way we can tell React to update the state of `anObject` with a new value for the `apples` property, but keeping the other fields unchanged, using the ES6 spread operator:

```react
const onClick = () => {
  setAnObject({
    ...anObject,
    apples: "100",
  });
};
```

We can also use the Immer library like so:

```react
import produce from 'immer';
//...

const onClick = () => {
  setAnObject(produce(draft => {
    draft.apples = 100;
  }));
};
```

This allows us to keep the familiar imperative style. It's also useful when the object we want to update is `n`-levels nested, because with the ES6 spread we potentially need to spread `n` number of times:

```react
import produce from 'immer';
//...

const onClick = () => {
  // with Immer
  setAnObject(produce(draft => {
    draft.order.apples = 100;
  }));

  // with ES6 spread
  setAnObject({
    ...draft,
    order: {
      ...draft.order,
      apples: 100,
    }
  });
};
```

The good folks at Immer have also published a `useImmer()` hook that allows you to simplify `setThing(produce(draft => ...))` to `updateThing(draft => ...)` - [check it out here](https://github.com/immerjs/use-immer).

## Conclusion

Mutating React state variables that are objects/arrays can cause unexpected behaviour. Immer is a useful addition to a React dev's toolbox, as it simplifies code to update React objects/arrays state especially when updating a property/entry that might be deeply nested.
