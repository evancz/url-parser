# URL Parser

This library helps you turn URLs into nicely structured data.

It is used in `elm-lang/navigation` to help folks create single-page applications (SPAs) where you manage the browser navigation yourself.


## Examples

Here is a parser that handles URLs like `/blog/42/whale-songs` where `42` can be any integer and `whale-songs` can be any string:

```elm
blog : Parser (Int -> String -> a) a
blog =
  s "blog" </> int </> string
```

Here is a slightly fancier example. This parser turns URLs like `/blog/42` and `/search/badger` into a nice structure that is easier to work with in Elm:

```elm
type Route
  = Blog Int
  | Search String

routes : Parser (Route -> a) a
routes =
  oneOf
  	[ format Blog (s "blog" </> int)
  	, format Search (s "search" </> string)
  	]
```


## Background

I first saw this general idea in Chris Done&rsquo;s [formatting][] library. Based on that, Noah and I outlined the API you see in this library. Noah then found Rudi Grinberg&rsquo;s [post][] about type safe routing in OCaml. It was exactly what we were going for. We had even used the names `s` and `(</>)` in our draft API! In the end, we ended up using the &ldquo;final encoding&rdquo; of the EDSL that had been left as an exercise for the reader. Very fun to work through! 😃

[formatting]: http://chrisdone.com/posts/formatting
[post]: http://rgrinberg.com/blog/2014/12/13/primitive-type-safe-routing/
