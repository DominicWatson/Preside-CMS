/**
 * A log of every email sent through the templating system
 *
 * @versioned                   false
 * @labelfield                  recipient
 * @datamanagerDefaultSortOrder datecreated desc
 * @dataExportFields            email_template,recipient,activity_type,activity_date,activity_link,activity_link_title,activity_link_body,activity_code,activity_reason
 * @datamanagerEnabled          true
 * @datamanagerSearchFields     email_template,recipient,subject
 * @feature                     emailCenter
 */
component extends="preside.system.base.SystemPresideObject" {
	property name="email_template"  relationship="many-to-one" relatedto="email_template" required=false indexes="template,template_created|1";
	property name="layout_override" type="string" dbtype="varchar" maxlength=200 required=false;
	property name="custom_layout"   type="string" dbtype="varchar" maxlength=200 required=false;
	property name="datecreated" indexes="datecreated,template_created|2";

	property name="website_user_recipient"  relationship="many-to-one" relatedto="website_user"  required=false feature="websiteUsers";
	property name="security_user_recipient" relationship="many-to-one" relatedto="security_user" required=false;

	property name="content" relationship="many-to-one" relatedto="email_template_send_log_content" required=false feature="emailCenterResend" excludeDataExport=true;

	property name="recipient" type="string" dbtype="varchar" maxlength=255 required=true indexes="recipient";
	property name="sender"    type="string" dbtype="varchar" maxlength=255 required=true indexes="sender";
	property name="subject"   type="string" dbtype="varchar" maxlength=255               indexes="subject";
	property name="resend_of" type="string" dbtype="varchar" maxlength=35                indexes="resendof";
	property name="send_args" type="string" dbtype="text" autofilter=false;

	property name="sent"           type="boolean" dbtype="boolean" default=false indexes="sent";
	property name="failed"         type="boolean" dbtype="boolean" default=false indexes="failed" renderer="booleanBadge";
	property name="delivered"      type="boolean" dbtype="boolean" default=false indexes="delivered";
	property name="hard_bounced"   type="boolean" dbtype="boolean" default=false indexes="hard_bounced";
	property name="opened"         type="boolean" dbtype="boolean" default=false indexes="opened";
	property name="marked_as_spam" type="boolean" dbtype="boolean" default=false indexes="marked_as_spam";
	property name="unsubscribed"   type="boolean" dbtype="boolean" default=false indexes="unsubscribed";

	property name="sent_date"           type="date" dbtype="datetime" indexes="sent_date";
	property name="failed_date"         type="date" dbtype="datetime" indexes="failed_date";
	property name="delivered_date"      type="date" dbtype="datetime" indexes="delivered_date";
	property name="hard_bounced_date"   type="date" dbtype="datetime" indexes="hard_bounced_date";
	property name="opened_date"         type="date" dbtype="datetime" indexes="opened_date";
	property name="marked_as_spam_date" type="date" dbtype="datetime" indexes="marked_as_spam_date";
	property name="unsubscribed_date"   type="date" dbtype="datetime" indexes="unsubscribed_date";

	property name="click_count" type="numeric" dbtype="int" default=0 indexes="click_count";
	property name="open_count"  type="numeric" dbtype="int" default=0 indexes="open_count";

	property name="failed_reason" type="string"  dbtype="text";
	property name="failed_code"   type="numeric" dbtype="int";

	property name="activities" relationship="one-to-many" relatedto="email_template_send_log_activity" relationshipkey="message";

	property name="activity_type"       formula="${prefix}activities.activity_type";
	property name="activity_ip"         formula="${prefix}activities.user_ip";
	property name="activity_user_agent" formula="${prefix}activities.user_agent";
	property name="activity_link"       formula="${prefix}activities.link";
	property name="activity_link_title" formula="${prefix}activities.link_title";
	property name="activity_link_body"  formula="${prefix}activities.link_body";
	property name="activity_code"       formula="${prefix}activities.code";
	property name="activity_reason"     formula="${prefix}activities.reason";
	property name="activity_date"       formula="${prefix}activities.datecreated" type="date" dbtype="datetime";

	property name="content_html" formula="${prefix}content.html_body";
	property name="content_text" formula="${prefix}content.text_body";
}