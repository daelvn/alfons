# alfons.wildcard

Reimplements the old filekit wildcard behavior
## API



| Element | Summary |
|---------|---------|
| **Functions** |  |
| [fromGlob](#fromGlob) | Turns a glob into a Lua pattern |
| [glob](#glob) | Returns a list of paths matched by the globs |
| [iglob](#iglob) | [`glob`](/alfons/wildcard#glob) as an iterator |
| [listAll](#listAll) | Filekit's listAll |
| [matchGlob](#matchGlob) | Matches a compiled glob with a string |

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>fromGlob</strong>&nbsp;
<span class='annotate'>:: glob:string -> pattern:string</span>
</div>


Turns a glob into a Lua pattern

- Turns a glob into a Lua pattern

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>glob</strong>&nbsp;
<span class='annotate'>:: glob:string -> paths:[string]</span>
</div>


Returns a list of paths matched by the globs

- Returns a list of paths matched by the globs

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>iglob</strong>&nbsp;
<span class='annotate'>:: glob:string -> -> path:string</span>
</div>


[`glob`](/alfons/wildcard#glob) as an iterator

- [`glob`](/alfons/wildcard#glob) as an iterator

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>listAll</strong>&nbsp;
<span class='annotate'>:: dir:string -> [string]</span>
</div>


Filekit's listAll

- Filekit's listAll

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>matchGlob</strong>&nbsp;
<span class='annotate'>:: pattern:string, path:string -> boolean</span>
</div>


Matches a compiled glob with a string

    This function is defined as `nil != path\match pattern`. In the future, this will be
    aliased to `testGlob` and the glob will be compiled in-place with [`fromGlob`](/alfons/wildcard#fromGlob).
