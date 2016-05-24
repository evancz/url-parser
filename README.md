# URL Parser

This library helps you turn URLs into nicely structured data.

It is designed to be used with `elm-lang/navigation` to help folks create single-page applications (SPAs) where you manage browser navigation yourself.


## Examples

Here is a parser that handles URLs like `/blog/42/whale-songs` where `42` can be any integer and `whale-songs` can be any string:

```elm
blog : Parser (Int -> String -> a) a
blog =
  s "blog" </> int </> string
```

Here is a slightly fancier example. This parser turns URLs like `/blog/42` and `/search/badger` into a nice structure that is easier to work with in Elm:

```elm
type DesiredPage = Blog Int | Search String

desiredPage : Parser (DesiredPage -> a) a
desiredPage =
  oneOf
    [ format Blog (s "blog" </> int)
    , format Search (s "search" </> string)
    ]
```

The actual `Parser` type is sort of tricky, so I think the best way to proceed is to just start using it. You can go far if you just assume it will do the intuitive thing.

> **Note:** If you want to dig deeper, I recommend figuring out the type of `int </> int` based on the type signatures for `int` and `</>`. You may be able to just know based on intuition, but instead, you should figure out exactly how every type variable gets unified. It is pretty cool! Again, you can use this library capably without looking into this at all, so do not worry about it if you do not care!


## Background

I first saw this general idea in Chris Done&rsquo;s [formatting][] library. Based on that, Noah and I outlined the API you see in this library. Noah then found Rudi Grinberg&rsquo;s [post][] about type safe routing in OCaml. It was exactly what we were going for. We had even used the names `s` and `(</>)` in our draft API! In the end, we ended up using the &ldquo;final encoding&rdquo; of the EDSL that had been left as an exercise for the reader. Very fun to work through! 😃

[formatting]: http://chrisdone.com/posts/formatting
[post]: http://rgrinberg.com/blog/2014/12/13/primitive-type-safe-routing/
