/**
 * The formbuilder_form object represents a single form within the form builder system
 *
 * @labelfield name
 * @datamanagerEnabled true
 */
component displayname="Form builder: form" extends="preside.system.base.SystemPresideObject" {
	property name="name"                   type="string"  dbtype="varchar" maxlength=255 required=true uniqueindexes="formname";
	property name="button_label"           type="string"  dbtype="varchar" maxlength=255 required=true;
	property name="form_submitted_message" type="string"  dbtype="text"                  required=true;
	property name="use_captcha"            type="boolean" dbtype="boolean"               required=false default=true;
	property name="description"            type="string"  dbtype="text"                  required=false;
	property name="locked"                 type="boolean" dbtype="boolean"               required=false default=false;
	property name="active"                 type="boolean" dbtype="boolean"               required=false default=false;
	property name="active_from"            type="date"    dbtype="datetime"              required=false;
	property name="active_to"              type="date"    dbtype="datetime"              required=false;
	property name="notification_enabled"   type="boolean" dbtype="boolean"               required=false default=false;

	property name="require_login"          type="boolean" dbtype="boolean" required=false default=false;
	property name="access_condition"       relationship="many-to-one" relatedto="rules_engine_condition" required=false control="conditionPicker" ruleContext="webrequest" ondelete="set-null-if-no-cycle-check" onupdate="cascade-if-no-cycle-check";
	property name="login_required_content" type="string"  dbtype="text"    required=false;
	property name="access_denied_content"  type="string"  dbtype="text"    required=false;

	property name="uses_global_questions" type="boolean" dbtype="boolean" required=false default=true feature="formbuilder2";

	property name="items" relationship="one-to-many" relatedto="formbuilder_formitem" relationshipKey="form";
}