/**
 * The log_entry object stores any log entries from logs using the
 * the PresideDbAppender log appender through logbox.
 *
 * @feature dbLogAppender
 */
component extends="preside.system.base.SystemPresideObject" noLabel=true versioned=false displayname="Log entry" {
	property name="id"          type="numeric" dbtype="bigint"  generator="increment";
	property name="severity"    type="string"  dbtype="varchar" maxLength="20" indexes="severity" required=true;
	property name="category"    type="string"  dbtype="varchar" maxLength="50" indexes="category" required=false default="none";
	property name="message"     type="string"  dbtype="text";
	property name="extra_info"  type="string"  dbtype="text";

	property name="admin_user_id" relationship="many-to-one" relatedTo="security_user" feature="admin";
	property name="web_user_id"   relationship="many-to-one" relatedTo="website_user"  feature="websiteUsers";

	property name="datemodified" deleted=true;
}