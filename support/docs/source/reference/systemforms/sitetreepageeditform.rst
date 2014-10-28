Sitetree Page: edit form
========================

*/forms/preside-objects/page/edit.xml*

This form is used as the base "edit page" form for Sitetree pages. See also :doc:`sitetreepageaddform`.

.. note::

	When an edit page form is rendered, it gets mixed in with any forms that are defined for the
	*page type* of the given page.

	See :doc:`/devguides/formlayouts` for a guide on form layouts and mixing forms.

	See :doc:`/devguides/pagetypes` for a guide to page types.

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>

    <form>
        <tab id="main" sortorder="10" title="preside-objects.page:editform.basictab.title" description="preside-objects.page:editform.basictab.description">
            <fieldset id="main" sortorder="10">
                <field sortorder="5" binding="page.parent_page" control="sitetreePagePicker" required="true" />
                <field sortorder="10" binding="page.title" />
                <field sortorder="20" binding="page.slug" required="true" />
                <field sortorder="30" binding="page.active" />
                <field sortorder="40" binding="page.main_image" />
                <field sortorder="50" binding="page.layout" />
                <field sortorder="60" binding="page.teaser" />
                <field sortorder="70" binding="page.main_content" />
            </fieldset>
        </tab>

        <tab id="meta" sortorder="20" title="preside-objects.page:editform.metadatatab.title" description="preside-objects.page:editform.metadatatab.description">
            <fieldset id="meta" sortorder="10">
                <field sortorder="10" binding="page.search_engine_access" />
                <field sortorder="20" binding="page.browser_title" />
                <field sortorder="30" binding="page.author" />
                <field sortorder="40" binding="page.description" />
            </fieldset>
        </tab>

        <tab id="dates" sortorder="30" title="preside-objects.page:editform.dateControlTab.title" description="preside-objects.page:editform.dateControlTab.description">
            <fieldset id="dates" sortorder="10">
                <field sortorder="10" binding="page.embargo_date" control="datepicker" />
                <field sortorder="20" binding="page.expiry_date"  control="datepicker" />
            </fieldset>
        </tab>

        <tab id="navigation" sortorder="40" title="preside-objects.page:editform.navigationtab.title" description="preside-objects.page:editform.navigationtab.description">
            <fieldset id="navigation" sortorder="10">
                <field sortorder="10" binding="page.navigation_title" control="textinput" placeholder="preside-objects.page:field.navigation_title.placeholder" />
                <field sortorder="20" binding="page.exclude_from_navigation" />
                <field sortorder="30" binding="page.exclude_children_from_navigation" />
            </fieldset>
        </tab>

        <tab id="access" sortorder="50" title="preside-objects.page:editform.accesstab.title" description="preside-objects.page:editform.accesstab.description">
            <fieldset id="access" sortorder="10">
                <field sortorder="10" binding="page.access_restriction" />
                <field sortorder="20" binding="page.full_login_required" />
                <field sortorder="30" name="grant_access_to_benefits" control="objectPicker" object="website_benefit" multiple="true" required="false" label="preside-objects.page:field.grant_access_to_benefits.title" help="preside-objects.page:field.grant_access_to_benefits.help" />
                <field sortorder="40" name="deny_access_to_benefits"  control="objectPicker" object="website_benefit" multiple="true" required="false" label="preside-objects.page:field.deny_access_to_benefits.title"  help="preside-objects.page:field.deny_access_to_benefits.help"  />
                <field sortorder="50" name="grant_access_to_users"    control="objectPicker" object="website_user"    multiple="true" required="false" label="preside-objects.page:field.grant_access_to_users.title"    help="preside-objects.page:field.grant_access_to_users.help"    />
                <field sortorder="60" name="deny_access_to_users"     control="objectPicker" object="website_user"    multiple="true" required="false" label="preside-objects.page:field.deny_access_to_users.title"     help="preside-objects.page:field.deny_access_to_users.help"     />
            </fieldset>
        </tab>
    </form>

