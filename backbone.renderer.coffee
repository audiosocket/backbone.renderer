if require?
  Backbone = require "backbone"
else
  Backbone = window.Backbone

# A mixin for objects with parent/child relationships.

Backbone.Ancestry =
  getChildren: ->
    @children ?= []

  # Get this instance's parent. Both `this.parent` and
  # `this.options.parent` are checked if they exist.

  getParent: ->
    @parent ?= @options?.parent

  # Does this instance have a parent?

  hasParent: ->
    not not @getParent()

  # Add a `child` instance. Sets the child's `parent` to
  # `this`. Returns `child`.

  addChild: (child) ->
    child.parent = this
    @getChildren().push child
    child

  # Create a new instance of `kind` and add it as a child, passing
  # along `attributes` and `options` to the constructor.
  # Returns the new instance.

  createChild: (kind, attributes, options) ->
    (attributes ||= {}).parent = this
    child = new kind attributes, options
    @addChild child
    child

  # Safely iterate over each child even if they're removed during
  # iteration. Returns `this`.

  eachChild: (fn) ->
    _(@getChildren()).chain().clone().each fn

  # Remove `child` from this instance's list of children. Returns
  # `child`.

  removeChild: (child) ->
    @getChildren().splice _.indexOf(@getChildren(), child), 1
    child

class Backbone.View extends Backbone.View
  _.extend @prototype, Backbone.Ancestry

  constructor: (options) ->
    # Retain model if we have one.
    options.model.retain() if options?.model?.retain?

    # Initialize empty insertedElements
    @insertedElements = {}

    super

  # Insert an element inside a template. Retain that element in @insertedElements
  # and return a <tag> HTML text element, to be replaced after rendering. tag is
  # used to make sure the returned text element can be apenned, e.g. tag should
  # be "option" if element is to be inserted within a <select> tag..

  insertElement: (tag, element) ->
    index = _.uniqueId("inserted_view_")

    @insertedElements[index] = element

    "<#{tag} data-inserted-view='#{index}'></#{tag}>"

  insertEachElement: (elements) ->
    _.map(elements, ([tag, element]) =>
      @insertElement tag, element).join "\n"

  insertView: (view) ->
    @insertElement view.tagName, view.el

  insertEachView: (views) ->
    @insertEachElement _.map(views, (view) ->
      [view.tagName, view.el])

  # Remove this view. Unbinds all incoming and outgoing events,
  # removes all children, releases @model if it exists, and removes
  # this view from its parent if it has one. Triggers the `removing`
  # event, returns `this`.

  remove: ->
    @trigger "removing"

    # Release our model if we had one.

    @model.release() if @model?.release?

    # Remove from the DOM.

    super

    # Kill all bindings for stuff that bound to us.

    @off()

    # Tell all our children to remove themselves.

    @eachChild (c) -> c.remove()

    # Remove ourselves from our parent, if we had one.

    @getParent().removeChild this if @hasParent()

    this

  render: ->
    @trigger "rendering"

    # Detach all inserted views
    _.each @insertedElements, (el) -> $(el).detach()

    # Reset inserted index and views
    @insertedElements = {}

    # Compile template.

    @$el.html @renderer()

    @delegateEvents()

    @trigger "rendered"

    # Reattach inserted elements. We re-attach _after_ triggering
    # "rendered" to make sure that all handlers on this event
    # do not mess with elements added now. Typical example:
    # @on "rendered" ->
    #   Backbone.ModelBinding.bind this
    # If elements are added before this, then Backbone.ModelBinding
    # will also change their values..
    # Same goes for @delegateEvents...

    _.each @insertedElements, (el, index) =>
      @$("[data-inserted-view='#{index}']").replaceWith el

    # Now we trigger "populated" if y'all need to do something when
    # sub-views have been attached.

    @trigger "populated"

    this

  renderer: ->
    "MISSING IMPLEMENTATION"
