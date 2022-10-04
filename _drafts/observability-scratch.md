

Agenda:
- Introduction

- How to do it?
  - backend setup
    - you can see requests to external systems, eg. Google authentication
  - frontend setup
    1. track it via a context
    2. report it
    3. propagate it

- What does it look like?

- hopefully this opens

Further work:
- What should I instrument?
- Why do I need observability?
- What makes a good trace?
- wavefront over zipkin / prometheus?
  - in the first place, what are the latter?

> “Monitoring” is best suited to report the overall health of systems. Aiming to “monitor everything” can prove to be an anti-pattern. Monitoring, as such, is best limited to key business and systems metrics derived from time-series based instrumentation, known failure modes as well as blackbox tests.
>
> “Observability”, on the other hand, aims to provide highly granular insights into the behavior of systems along with rich context, perfect for debugging purposes. Since it’s still not possible to predict every single failure mode a system could potentially run into or predict every possible way in which a system could misbehave, it becomes important that we build systems that can be debugged armed with evidence and not conjecture.

> “monitoring” which is known failure centric, “observability” doesn’t necessarily have to be closely tied to an outage or a user complaint. It can be used as a way to better understand system performance and behavior, even during the what can be perceived as “normal” operation of a system.



## What makes a good trace?

 - high cardinality

  > high-cardinality information is the most useful data for debugging or understanding a system (think user IDs, shopping cart IDs, request IDs ... basically any IDs and also instances, container, build number, span ID, etc). Unique IDs will always do the best job of identifying individual needles in a given haystack.

## Why do I need observability?

Why should I be interested?

> "When we blew up the monolith into many services, we lost the ability to step through our code with a debugger: it now hops the network. Our tools are still coming to grips with this seismic shift."

> I see a huge spike in errors at the edge at 2 p.m. today. Let’s explore. I will break down by replica set (or endpoint, or user, or literally anything, but let’s say replica set for now). Okay, there’s a huge spike in errors to replica set 1, and a much smaller spike in errors to two other replica sets, 4 and 5. Interesting. The queue lengths appear to steadily climb through the length of the spike on replica set 1, and bounce up and down through the duration on 4, and just a short spike on 5. There is a long-running query on rs1, and not the other two. I wonder if it’s a transient problem with EBS/IOPS — so I will break down by replica set node and availability zone, which shows me that they are on different AZs. Cool, ruled that one out. Is it a migration? No, the build_id didn’t change. Let me sum up the lock time being held and break down by user_id and sort to see who is holding the lock and for which query — AH! this is coming from a background expiration job from cron! It lasted longer on RS1 than RS4/5 because there was more older data there. Let’s rework it so it doesn’t have to contend for the lock in this way. <!-- .element: style="font-size: 0.48em" -->

[Observability — A 3-Year Retrospective](https://thenewstack.io/observability-a-3-year-retrospective/) <!-- .element: style="font-size: 0.48em; right: -20%" -->

Note:
What is the goal of observability? It allows you to do this - debugging. Unknown-unknowns



<!-- ![Youtube, example of SPA]({{ "/public/img/2020-09-03-observability-and-the-frontend-initial-steps/Youtube-spa-example.png" | relative_url}}) --> <!-- .element: style="max-width: 80%; margin: 0" -->



Note:
...

- Routing (in your favourite framework)
  - `@angular/router`
  - `react-router-dom`

(old)
### Identify unit of work to be a trace/span

What is the appropriate level of granularity?

### Backend calls

- API calls are child spans of the navigation span.






<!-- .slide: data-background-image="{{ "/public/img/2020-09-03-observability-and-the-frontend-initial-steps/Observability-A-3-Year-Retrospective.png" | relative_url}}" data-background-size="50%" -->

Note:
Observability - A 3-Year Retrospective https://thenewstack.io/observability-a-3-year-retrospective/
   - The ‘00s Spawned a New Vendor Breed: APM
   - Cardinality and Its Relation to Complex Distributed Systems
     - Without Access to High Cardinality Data, Good Luck Debugging
   - What Observability Looks Like in Practice
   - Observability and Its Progenitors
   - How Observability’s Purpose and Value Have Been Misrepresented
   - The Future of Observability
   - Engage in Constant Conversation with Your Code
   - For Engineers … but also Engineering-adjacent Teams


<!-- .slide: data-background-image="{{ "/public/img/2020-09-03-observability-and-the-frontend-initial-steps/Monitoring-and-Observability.png" | relative_url}}" data-background-size="80%" -->

Note:
https://medium.com/@copyconstruct/monitoring-and-observability-8417d1952e1c
   - Baby’s first Observability
   - Monitoring is for symptom based Alerting
   - And then there’s “Observability”
   - Debugging
   - Context Matters
   - One last thing



<!-- .slide: data-background-image="{{ "/public/img/2020-09-03-observability-and-the-frontend-initial-steps/Tutorial-Adding-distributed-tracing-instrumentation.png" | relative_url}}" data-background-size="50%" -->




Further work

- rendering time
  - DomContentReady / `timing_first_contentful_paint_ms` is only for first load
- other significant user interactions, eg. form submissions
  - https://docs.honeycomb.io/getting-data-in/javascript/browser-js/
- root span = one `NavigationStart` to next `NavigationStart`?
- root span = log in to log out?
