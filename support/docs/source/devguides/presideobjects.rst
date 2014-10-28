Preside Data Objects
====================

Overview
########

**Preside Data Objects** are the data layer implementation for PresideCMS. Just about everything in the system that persists data to the database uses Preside Data Objects to do so. 

The Preside Data Objects system is deeply integrated into the CMS:

* Input forms and other administrative GUIs can be automatically generated for your preside objects (see :doc:`formlayouts`)
* :doc:`presideobjectviews` provide a way to present your data to end users without the need for handler or service layers
*  The see :doc:`datamanager` provides a GUI for managing your client specific data and is based on entirely on Preside Data Objects
* Your preside objects can have their data tied to individual :doc:`sites`, without the need for any extra programming of site filters, see :ref:`presideobjectssites`

The following guide is intended as a thorough overview of Preside Data Objects. For API reference documentation, see :doc:`/reference/api/presideobjectservice` (service layer) and :doc:`/reference/presideobjects/index` (system provided data objects).


Object CFC Files
################

Data objects are represented by ColdFusion Components (CFCs). A typical object will look something like this:

.. code-block:: java

    component output=false {
        property name="name"          type="string" dbtype="varchar" maxlength="200" required=true;
        property name="email_address" type="string" dbtype="varchar" maxlength="255" required=true uniqueindexes="email";

        property name="tags" relationship="many-to-many" relatedto="tag";
    }

A singe CFC file represents a table in your database. Properties defined using the :code:`property` tag represent fields and/or relationships on the table (see :ref:`preside-objects-properties`, below). 

Database table names
--------------------

By default, the name of the database table will be the name of the CFC file prefixed with **pobj_**. For example, if the file was :code:`person.cfc`, the table name would be **pobj_person**.

You can override these defaults with the :code:`tablename` and :code:`tableprefix` attributes:

.. code-block:: java

    component tablename="mytable" tableprefix="mysite_" output=false {
        // .. etc.
    }

.. note::

    All of the preside objects that are provided by the core PresideCMS system have their table names prefixed with **psys_**.

Registering objects
-------------------
    
The system will automatically register any CFC files that live under the :code:`/application/preside-objects` folder of your site (and any of its sub-folders). Each .cfc file will be registered with an ID that is the name of the file without the ".cfc" extension. 

For example, given the directory structure below, *four* objects will be registered with the IDs *blog*, *blogAuthor*, *event*, *eventCategory*:

.. code-block:: text

    /application
        /preside-objects
            /blogs
                blog.cfc
                blogAuthor.cfc
            /events
                event.cfc
                eventCategory.cfc

.. note::

    Notice how folder names are ignored. While it is useful to use folders to organise your Preside Objects, they carry no logical meaning in the system.

Extensions and core objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~

For extensions, the system will search for CFC files in a :code:`/preside-objects` folder at the root of your extension.

Core system Preside Objects can be found at :code:`/preside/system/preside-objects`. See :doc:`/reference/presideobjects/index` for reference documentation.

.. _preside-objects-properties:

Properties
##########

Properties represent fields on your database table or mark relationships between objects (or both).

Attributes of the properties describe details such as data type, data length and validation requirements. At a minimum, your properties should define a *name*, *type* and *dbtype* attribute. For *varchar* fields, a *maxLength* attribute is also required. You will also typically need to add a *required* attribute for any properties that are a required field for the object:

.. code-block:: java

    component output=false {
        property name="name"          type="string"  dbtype="varchar" maxLength="200" required=true;
        property name="max_delegates" type="numeric" dbtype="int"; // not required
    }

Standard attributes
-------------------

While you can add any arbitrary attributes to properties (and use them for your own business logic needs), the system will interpret and use the following standard attributes:

=================  =============  =========  ===============================================================================================================================================================================================================================================================
Name               Required       Default    Description
=================  =============  =========  ===============================================================================================================================================================================================================================================================
**name**           Yes            *N/A*      Name of the field
**type**           No             "string"   CFML type of the field. Valid values: *string*, *numeric*, *boolean*, *date*
**dbtype**         No             "varchar"  Database type of the field to be define on the database table field        
**maxLength**      No             0          For dbtypes that require a length specification. If zero, the max size will be used.
**required**       No             **false**  Whether or not the field is required.    
**default**        No             ""         A default value for the property. Can be dynamically created, see :ref:`presideobjectsdefaults`
**indexes**        No             ""         List of indexes for the field, see :ref:`preside-objects-indexes`
**uniqueindexes**  No             ""         List of unique indexes for the field, see :ref:`preside-objects-indexes`
**control**        No             "default"  The default form control to use when rendering this field in a Preside Form. If set to 'default', the value for this attribute will be calculated based on the value of other attributes. See :doc:`/devguides/formcontrols` and :doc:`/devguides/formlayouts`.
**renderer**       No             "default"  The default content renderer to use when rendering this field in a view. If set to 'default', the value for this attribute will be calculated based on the value of other attributes. (reference needed here).
**minLength**      No             *none*     Minimum length of the data that can be saved to this field. Used in form validation, etc. 
**minValue**       No             *none*     The minumum numeric value of data that can be saved to this field. *For numeric types only*.
**maxValue**       No             *N/A*      The maximum numeric value of data that can be saved to this field. *For numeric types only*.
**format**         No             *N/A*      Either a regular expression or named validation filter (reference needed) to validate the incoming data for this field
**pk**             No             **false**  Whether or not this field is the primary key for the object, *one field per object*. By default, your object will have an *id* field that is defined as the primary key. See :ref:`preside-objects-default-properties` below.
**generator**      No             "none"     Named generator for generating a value for this field when inserting a new record with the value of this field ommitted. Valid values are *increment* and *UUID*. Useful for primary key generation.
**relationship**   No             "none"     Either *none*, *many-to-one* or *many-to-many*. See :ref:`preside-objects-relationships`, below.
**relatedTo**      No             "none"     Name of the Preside Object that the property is defining a relationship with. See :ref:`preside-objects-relationships`, below.
=================  =============  =========  ===============================================================================================================================================================================================================================================================


.. _preside-objects-default-properties:

Default properties
------------------

The bare minimum code requirement for a working Preside Data Object is:

.. code-block:: java

    component output=false {}

Yes, you read that right, an "empty" CFC is an effective Preside Data Object. This is because, by default, Preside Data Objects will be automatically given  :code:`id`, :code:`label`, :code:`datecreated` and :code:`datemodified` properties. The above example is equivalent to:

.. code-block:: java

    component output=false {
        property name="id"           type="string" dbtype="varchar"   required=true maxLength="35" generator="UUID" pk=true;
        property name="label"        type="string" dbtype="varchar"   required=true maxLength="250";
        property name="datecreated"  type="date"   dbtype="timestamp" required=true;
        property name="datemodified" type="date"   dbtype="timestamp" required=true;
    }

The ID Field
~~~~~~~~~~~~

The ID field will be the primary key for your object. We have chosen to use a UUID for this field so that data migrations between databases are achievable. If, however, you wish to use an auto incrementing numeric type for this field, you could do so by overriding the :code:`type`, :code:`dbtype` and :code:`generator` attributes:

.. code-block:: java

    component output=false {
        property name="id" type="numeric" dbtype="int" generator="increment";
    }

The same technique can be used to have a primary key that does not use any sort of generator (you would need to pass your own IDs when inserting data):

.. code-block:: java

    component output=false {
        property name="id" generator="none";
    }

.. tip::

    Notice here that we are just changing the attributes that we want to modify (we do not specify :code:`required` or :code:`pk` attributes). All the default attributes will be applied unless you specify a different value for them.

.. _presideobjectslabelfield:

The Label field
~~~~~~~~~~~~~~~

The **label** field is used by the system for building automatic GUI selectors that allow users to choose your object records. 

    .. figure:: /images/object_picker_example.png

        Screenshot showing a record picker for a "Blog author" object


If you wish to use a different property to represent a record, you can use the :code:`labelfield` attribute on your CFC, e.g.:

.. code-block:: java

    component output=false labelfield="title" {
        property name="title" type="string" dbtype="varchar" maxlength="100" required=true;
        // etc. 
    }

If you do not want your object to have a label field at all (i.e. you know it is not something that will ever be selectable, and there is no logical field that might be used as a string representation of a record), you can add a :code:`nolabel=true` attribute to your CFC:

.. code-block:: java

    component output=false nolabel=true {
        // ... etc.
    }

The DateCreated and DateModified fields
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These do exactly what they say on the tin. If you use the APIs to insert and update your records, the values of these fields will be set automatically for you.


.. _presideobjectsdefaults:

Default values for properties
-----------------------------

You can use the :code:`default` attribute on a property tag to define a default value for a property. This value will be used during an :ref:`presideobjectservice-insertdata` operation when no value is supplied for the property. E.g.

.. code-block:: java

    component output=false {
        // ...
        property name="max_attendees" type="numeric" dbtype="int" required=false default=100;
    }

Dynamic defaults
~~~~~~~~~~~~~~~~

Default values can also be generated dynamically at runtime. Currently, this comes in two flavours: 

1. Supplying raw CFML to be evaluated at runtime
2. Supplying the name of a method defined in your object that will be called at runtime, this method will be passed a 'data' argument that is a structure containing the data to be inserted

For raw CFML, prefix your value with :code:`cfml:`, e.g. :code:`cfml:CreateUUId()`. For methods that are defined on your object, use :code:`method:methodName`. e.g.

.. code-block:: java

    component output=false  {
        // ...
        property name="event_start_date" type="date"   dbtype="timestamp"                 required=false default="cfml:Now()";
        property name="slug"             type="string" dbtype="varchar"   maxlength="200" required=false default="method:calculateSlug";

        public string function calculateSlug( required struct data ) output=false {
            return LCase( ReReplace( data.label ?: "", "\W", "_", "all" ) );
        }
    }

.. _preside-objects-relationships:

Defining relationships with properties
--------------------------------------

Relationships are defined on **property** tags using the :code:`relationship` and :code:`relatedTo` attributes. For example:

.. code-block:: java

    // eventCategory.cfc
    component output=false {}

    // event.cfc
    component output=false {
        property name="category" relationship="many-to-one" relatedto="eventCategory" required=true;
    }    

If you do not specify a :code:`relatedTo` attribute, the system will assume that the foreign object has the same name as the property field. For example, the two objects below would be related through the :code:`eventCategory` property of the :code:`event` object:

.. code-block:: java

    // eventCategory.cfc
    component output=false {}

    // event.cfc
    component output=false {
        property name="eventCategory" relationship="many-to-one" required=true;
    }    

One to Many relationships
~~~~~~~~~~~~~~~~~~~~~~~~~

In the examples, above, we define a **one to many** style relationship between :code:`event` and :code:`eventCategory` by adding a foreign key property to the :code:`event` object.

The :code:`category` property will be created as a field in the :code:`event` object's database table. Its datatype will be automatically derived from the primary key field in the :code:`eventCategory` object and a Foreign Key constraint will be created for you.

.. note::

    The :code:`event` object lives on the **many** side of this relationship (there are *many events* to *one category*), hence why we use the relationship type, *many-to-one*.

Many to Many relationships
~~~~~~~~~~~~~~~~~~~~~~~~~~

If we wanted an event to be associated with multiple event categories, we would want to use a **Many to Many** relationship:

.. code-block:: java

    // eventCategory.cfc
    component output=false {}

    // event.cfc
    component output=false {
        property name="eventCategory" relationship="many-to-many";
    }

In this scenario, there will be no :code:`eventCategory` field created in the database table for the :code:`event` object. Instead, a "pivot" database table will be automatically created that looks a bit like this (in MySQL):

.. code-block:: sql

    -- table name derived from the two related objects, delimited by __join__
    create table `pobj_event__join__eventcategory` (
        -- table simply has a field for each related object
          `event`         varchar(35) not null
        , `eventcategory` varchar(35) not null

        -- plus we always add a sort_order column, should you care about 
        -- the order in which records are related
        , `sort_order`    int(11)     default null
        
        -- unique index on the event and eventCategory fields
        , unique key `ux_event__join__eventcategory` (`event`,`eventcategory`)

        -- foreign key constraints on the event and eventCategory fields
        , constraint `fk_1` foreign key (`event`        ) references `pobj_event`         (`id`) on delete cascade on update cascade
        , constraint `fk_2` foreign key (`eventcategory`) references `pobj_eventcategory` (`id`) on delete cascade on update cascade
    ) ENGINE=InnoDB;

.. note::

    Unlike **many to one** relationships, the **many to many** relationship can be defined on either or both objects in the relationship. That said, you will want to define it on the object(s) that make use of the relationship. In the event / eventCategory example, this will most likely be the event object. i.e. :code:`event.insertData( label=eventName, eventCategory=listOfCategoryIds )`.


.. _preside-objects-indexes:

Defining indexes and unique constraints
---------------------------------------

The Preside Object system allows you to define database indexes on your fields using the :code:`indexes` and :code:`uniqueindexes` attributes. The attributes expect a comma separated list of index definitions. An index definition can be either an index name or combination of index name and field position, separated by a pipe character. For example:

.. code-block:: java

    // event.cfc
    component output=false {
        property name="category" indexes="category,categoryName|1" required=true relationship="many-to-one" ;
        property name="name"     indexes="categoryName|2"          required=true type="string" dbtype="varchar" maxlength="100";
        // ...
    }

The example above would result in the following index definitions:

.. code-block:: sql

    create index ix_category     on pobj_event( category );
    create index ix_categoryName on pobj_event( category, name );

The exact same syntax applies to unique indexes, the only difference being the generated index names are prefixed with :code:`ux_` rather than :code:`ix_`.

.. _preside-objects-keeping-in-sync-with-db:

Keeping in sync with the database
#################################

When you reload your application (see :doc:`reloading`), the system will attempt to synchronize your object definitions with the database. While it does a reasonably good job at doing this, there are some considerations:

* If you add a new, required, field to an object that has existing data in the database, an exception will be raised. This is because you cannot add a :code:`NOT NULL` field to a table that already has data. *You will need to provide upgrade scripts to make this type of change to an existing system.*

* When you delete properties from your objects, the system will rename the field in the database to :code:`_deprecated_yourfield`. This prevents accidental loss of data but can lead to a whole load of extra fields in your DB during development.

* The system never deletes whole tables from your database, even when you delete the object file

Working with the API
####################

The :doc:`/reference/api/presideobjectservice` service object provides methods for performing CRUD operations on the data along with other useful methods for querying the metadata of each of your data objects. There are two ways in which to interact with the API:

1. Obtain an instance the :doc:`/reference/api/presideobjectservice` and call its methods directly, see :ref:`preside-objects-get-api-instance`
2. Obtain an "auto service object" for the specific object you wish to work with and call its decorated CRUD methods as well as any of its own custom methods, see :ref:`preside-objects-auto-service-objects`

You may find that all you wish to do is to render a view with some data that is stored through the Preside Object service. In this case, you can bypass the service layer APIs and use the :doc:`presideobjectviews` system instead.


.. _preside-objects-get-api-instance:

Getting an instance of the Service API
--------------------------------------

We use Wirebox_ to auto wire our service layer. To inject an instance of the service API into your service objects and/or handlers, you can use wirebox's "inject" syntax as shown below:

.. code-block:: java

    // a handler example
    component output=false {
        property name="presideObjectService" inject="presideObjectService";

        function index( event, rc, prc ) output=false {
            prc.eventRecord = presideObjectService.selectData( objectName="event", id=rc.id ?: "" );

            // ...
        }
    }

    // a service layer example
    // (here at Pixl8, we prefer to inject constructor args over setting properties)
    component output=false {

        /**
         * @presideObjectService.inject presideObjectService
         */
         public any function init( required any presideObjectService ) output=false {
            _setPresideObjectService( arguments.presideObjectService );

            return this;
         }

         public query function getEvent( required string id ) output=false {
            return _getPresideObjectService().selectData(
                  objectName = "event"
                , id         = arguments.id
            );
         }

         // we prefer private getters and setters for accessing private properties, this is our house style
         private any function _getPresideObjectService() output=false {
             return variables._presideObjectService;
         }
         private void function _setPresideObjectService( required any presideObjectService ) output=false {
             variables._presideObjectService = arguments.presideObjectService;
         }

    }


.. _preside-objects-auto-service-objects:

Using Auto Service Objects
--------------------------

An auto service object represents an individual data object. They are an instance of the given object that has been decorated with the service API CRUD methods.

Calling the CRUD methods works in the same way as with the main API with the exception that the objectName argument is no longer required. So:

.. code-block:: java

    record = presideObjectService.selectData( objectName="event", id=id );

    // is equivalent to:
    eventObject = presideObjectService.getObject( "event" );
    record      = eventObject.selectData( id=id );


Getting an auto service object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This can be done using either the :ref:`presideobjectservice-getobject` method of the Preside Object Service or by using a special Wirebox DSL injection syntax, i.e.

.. code-block:: java

    // a handler example
    component output=false {
        property name="eventObject" inject="presidecms:object:event";

        function index( event, rc, prc ) output=false {
            prc.eventRecord = eventObject.selectData( id=rc.id ?: "" );

            // ...
        }
    }

    // a service layer example
    component output=false {

        /**
         * @eventObject.inject presidecms:object:event
         */
         public any function init( required any eventObject ) output=false {
            _setPresideObjectService( arguments.eventObject );

            return this;
         }

         public query function getEvent( required string id ) output=false {
            return _getEventObject().selectData( id = arguments.id );
         }

         // we prefer private getters and setters for accessing private properties, this is our house style
         private any function _getEventObject() output=false {
             return variables._eventObject;
         }
         private void function _setEventObject( required any eventObject ) output=false {
             variables._eventObject = arguments.eventObject;
         }

    }

CRUD Operations
---------------

The service layer provides core methods for creating, reading, updating and deleting records (see individual method documentation for reference and examples):

* :ref:`presideobjectservice-selectdata`
* :ref:`presideobjectservice-insertdata`
* :ref:`presideobjectservice-updatedata`
* :ref:`presideobjectservice-deletedata`

In addition to the four core methods above, there are also further utility methods for specific scanarios:

* :ref:`presideobjectservice-dataexists`
* :ref:`presideobjectservice-selectmanytomanydata`
* :ref:`presideobjectservice-syncmanytomanydata`
* :ref:`presideobjectservice-getdenormalizedmanytomanydata`
* :ref:`presideobjectservice-getrecordversions`


.. _presideobjectsselectfields:

Specifying fields for selection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`presideobjectservice-selectdata` method accepts a :code:`selectFields` argument that can be used to specify which fields you wish to select. This can be used to select properties on your object as well as properties on related objects and any plain SQL aggregates or other SQL operations. For example:

.. code-block:: java

    records = newsObject.selectData(
        selectFields = [ "news.id", "news.title", "Concat( category.label, category$tag.label ) as catandtag"  ]
    );

The example above would result in SQL that looked something like:

.. code-block:: sql

    select      news.id
              , news.title
              , Concat( category.label, tag.label ) as catandtag

    from        pobj_news     as news
    inner join  pobj_category as category on category.id = news.category
    inner join  pobj_tag      as tag      on tag.id      = category.tag

.. note:: 

    The funky looking :code:`category$tag.label` is expressing a field selection across related objects - in this case **news** -> **category** -> **tag**. See :ref:`presideobjectsrelationships` for full details.

.. _preside-objects-filtering-data:

Filtering data
~~~~~~~~~~~~~~

All but the **insertData()** methods accept a data filter to either refine the returned recordset or the records to be updated / deleted. The API provides two arguments for filtering, :code:`filter` and :code:`filterParams`. Depending on the type of filtering you need, the :code:`filterParams` argument will be optional.

Simple filtering
................

A simple filter consists of one or more strict equality checks, all of which must be true. This can be expressed as a simple CFML structure; the structure keys represent the object fields; their values represent the expected record values:

.. code-block:: java

    records = newsObject.selectData( filter={
          category             = chosenCategory
        , "category$tag.label" = "red"
    } );

.. note:: 

    The funky looking :code:`category$tag.label` is expressing a filter across related objects - in this case **news** -> **category** -> **tag**. We are filtering news items whos category is tagged with a tag who's label field = "red". See :ref:`presideobjectsrelationships`.

Complex filters
...............

More complex filters can be achieved with a plain SQL filter combined with filter params to make use of parametized SQL statements:

.. code-block:: java

    records = newsObject.selectData( 
          filter       = "category != :category and DateDiff( publishdate, :publishdate ) > :daysold and category$tag.label = :category$tag.label"
        , filterParams = {
               category             = chosenCategory
             , publishdate          = publishDateFilter
             , "category$tag.label" = "red"
             , daysOld              = { type="integer", value=3 }
          } 
    );

.. note::

    Notice that all but the *daysOld* filter param do not specify a datatype. This is because the parameters can be mapped to fields on the object/s and their data types derived from there. The *daysOld* filter has no field mapping and so its data type must also be defined here.

.. _presideobjectsrelationships:

Making use of relationships
~~~~~~~~~~~~~~~~~~~~~~~~~~~

As seen in the examples above, you can use a special field syntax to reference properties in objects that are related to the object that you are selecting data from / updating data on. When you do this, the service layer will automatically create the necessery SQL joins for you. 

The syntax takes the form: :code:`(relatedObjectReference).(propertyName)`. The related object reference can either be the name of the related object, or a :code:`$` delimited path of property names that navigate through the relationships (see examples below).

This syntax can be used in:

* Select fields, see :ref:`presideobjectsselectfields`
* Filters. see :ref:`preside-objects-filtering-data`
* Order by statements
* Group by statements

To help with the examples, we'll illustrate a simple relationship between three objects:

.. code-block:: java

    // tag.cfc
    component output=false {}

    // category.cfc
    component output=false {
        property name="category_tag" relationship="many-to-one" relatedto="tag" required=true;
        // ..
    }

    // news.cfc
    component output=false {
        property name="news_category" relationship="many-to-one" relatedto="category" required=true;
        // ..
    }

Syntax by example:

.. code-block:: java

    // flavour 1: auto join on just object name
    // update news items who's category tag = "red"
    presideObjectService.updateData(
          objectName = "news"
        , data       = { archived = true }
        , filter     = { "tag.label" = "red" } // the system will automatically figure out the relationship path between the news object and the tag object
    );

    // flavour 2: using property names that define relationships
    // 2a. joining to one immediately related object
    // delete news items who's category label = "red"
    presideObjectService.deleteData(
          objectName = "news"
        , data       = { archived = true }
        , filter     = { "news_category.label" = "red" } 
    );

    // 2b. joining through multiple objects (note the $ delimiter to denote that the next property will also define a relationship)
    // select title and category tag from all news objects, order by the category tag
    presideObjectService.selectData(
          objectName   = "news"
        , selectFields = [ "news.title", "news_category$category_tag.label as tag" ]
        , orderby      = "news_category$category_tag.label"
    );
    


Auto joins vs. specific column join mappings
............................................

While the auto join syntax (just referencing by related object name) can be really useful, it is limited to cases where there is only a single relationship path between the two objects. If there are multiple ways in which you could join the two objects, the system can have no way of knowing which path it should take.

Caching
~~~~~~~

By default, all :ref:`presideobjectservice-selectData` calls have their recordset results cached. These caches are automatically cleared when the data changes.

You can specify *not* to cache results with the :code:`useCache` argument.

See :doc:`caching` for a full guide to configuring and creating caches, including how to configure the default query cache used here.


.. _presideobjectsextending:

Extending Objects
#################

.. tip::

    You can easily extend core data objects and objects that have been provided by extensions simply by creating :code:`.cfc` file with the same name. 

Objects with the same name, but from different sources, are merged at runtime so that you can have multiple extensions all contributing to the final object definition.

Take the :doc:`/reference/presideobjects/page` object, for example. You might write an extension that adds an **allow_comments** property to the object. That CFC would look like this:

.. code-block:: java

    // /extensions/myextension/preside-objects/page.cfc
    component output=false {
        property name="allow_comments" type="boolean" dbtype="boolean" required=false default=true;
    }

After adding that code and reloading your application, you would find that the **psys_page** table now had an **allow_comments** field added.

Then, in your site, you may have some client specific requirements that you need to implement for all pages. Simply by creating a :code:`page.cfc` file under your site, you can mix in properties along with the **allow_comments** mixin above:

.. code-block:: java

    // /application/preside-objects/page.cfc
    component output=false {
        // remove a property that has been defined elsewhere
        property name="embargo_date" deleted=true;

        // alter attributes of an existing property
        property name="title" maxLength="50"; // strict client requirement?!

        // add a new property
        property name="search_engine_boost" type="numeric" dbtype="integer" minValue=0 maxValue=100 default=0;
    }

.. note::

    To have your object changes reflected in GUI forms (i.e. the add and edit page forms in the example above), you will likely need to modify the form definitions for the object you have changed. See :doc:`formlayouts` for a full guide and reference (hint: the same system of mixed in extensions is used for form layouts).

Versioning
##########

By default, Preside Data Objects will maintain a version history of each database record. It does this by creating a separate database table that is prefixed with :code:`_version_`. For example, for an object named 'news', a version table named **_version_pobj_news** would be created.

The version history table contains the same fields as its twin as well as a few specific fields for dealing with version numbers, etc. All foreign key constraints and unique indexes are removed.

Opting out
----------

To opt out of versioning for an object, you can set the :code:`versioned` attribute to **false** on your CFC file:

.. code-block:: java
    
    component versioned=false output=false {
        // ...
    }

Interacting with versions
-------------------------

Various admin GUIs such as the :doc:`datamanager` implement user interfaces to deal with versioning records. However, if you find the need to create your own, or need to deal with version history records in any other way, you can use methods provided by the service api:

* :ref:`presideobjectservice-getrecordversions`
* :ref:`presideobjectservice-getversionobjectname`
* :ref:`presideobjectservice-objectisversioned`
* :ref:`presideobjectservice-getnextversionnumber`

In addition, you can specify whether or not you wish to use the versioning system, and also what version number to use if you are, when calling the :ref:`presideobjectservice-insertData`, :ref:`presideobjectservice-updateData` and :ref:`presideobjectservice-deleteData` methods by using the :code:`useVersioning` and :code:`versionNumber` arguments.

Finally, you can select data from the version history tables with the :ref:`presideobjectservice-selectdata` method by using the :code:`fromVersionTable`, :code:`maxVersion` and :code:`specificVersion` arguments.

.. _presideobjectssites:

Organising data by sites
########################

You can instruct the Preside Data Objects system to organise your objects' data into your system's individual sites (see :doc:`sites`). Doing so will mean that any data reads and writes will be specific to the currently active site.

To enable this feature for an object, simply add the :code:`siteFiltered` attribute to the :code:`component` tag:

.. code-block:: java

    component output=false siteFiltered=true {
        // ...
    }




.. _Wirebox: http://wiki.coldbox.org/wiki/WireBox.cfm