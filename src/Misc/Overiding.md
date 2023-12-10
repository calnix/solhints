Overriding function visibility. You can override the visibility of a function:

- from external to public ✅
- but not from public to external ❌

Therefore, the function visibility can be overriding by opening it up, from only being called by the external world to also being able to call the function from within the contract (through inheritance).
You should mark the functions to the most restricted visibility first, and then open up the visibility by overriding.