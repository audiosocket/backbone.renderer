backbone.renderer
=================

backbone.renderer provides useful extensions for managing [Backbone](http://backbonejs.org/)'s views rendering.

These extensions allow to define a hierarchy of views, sub-views, sub-sub-views, etc.. When the top-level view 
is rendered, all its child views are inserted into the top-level view's element.

Likewise, when the top-level view is removed, all its child views are also removed.

Extensions
----------

All `Backbone.View` are extended with the following methods:

* `createChild`, `removeChild` for views hierarchy management
* `insertElement`, `insertEachElement`, `insertView`, `insertEachView` for inserting sub-views in view's templates
* `render`, `remove` for rendering/removing views hiearchy.

They are used as follows:

Declaring child views
---------------------

A views descending from a parent view must be declared using `@createChild`. For instance:

```
class App.View.Store extends Backbone.View
  initialize: ->
    @account = @createChild App.View.Account
```

You do not need to write the corresponding `@removeChild` as this is done implicetely when calling `view.remove()`.

Rendering views
---------------

In order to render views, you need to provide a `renderer` method, which should return the HTML content of that
view. You can use there the various insertion methods. For instance:

```
  rendered: ->
    """
      <h1>You account informations</h1>
      #{@insertView @account}
    """
```

Then, when calling `view.render()`, `view.account.el` will be added to `view.el` appropriately.

**Please note** that `render` calls are not propagated. Calling `view.render()` does
not call `view.account.render()`. Rendering in a timely fashion is left for your application to implement.

Removing views
--------------

You can call `view.remove()` to remove a view. It will also recursively call `remove` on all its herarchy of sub-views.

Backbone.Ancestry
-----------------

Child management is done using the mixin `Backbone.Ancestry`. You may refer to its code as it may also be 
useful for your application.

backbone.modelizer
------------------

If [backbone.modelizer](https://github.com/audiosocket/backbone.modelizer/) is also installed, this module will
call `model.retain()` on a view's model, if it exists, when initializing the view  and `model.release()` when
`view.remove()` is called.

Using
=====

You should include `backbone.renderify.js` after including `jquery`, `underscore`, `backbone.js`
and `backbone.modelizer.js` and before including any of your model classes.
