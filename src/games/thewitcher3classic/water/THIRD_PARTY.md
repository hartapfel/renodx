The previous-frame raw-HDR SSR input approach and four-tap prefilter follow
[BlitzFX](https://github.com/sven-luepke/blitz-fx), commit
`659e239cfcba9cf0362621486ecdb241b0eee168`:

- `resources/shaders_v2/water/PreSSRDownsamplePS.hlsl`
- `source/rendering/effects/post_processing_renderer.cpp`

Our integration uses native Classic SSR, its existing temporal clamp/composite,
RenoDX's render dimensions, and additional depth/camera/history validation.
It does not copy BlitzFX's complete water renderer or require BlitzFX to load.

MIT License

Copyright (c) 2024 Sven Lüpke

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
