/**
 * @expressionCategory formbuilder
 * @expressionContexts user
 * @expressionTags     formbuilderV2Form
 * @feature            websiteusers
 */
component {

	property name="formBuilderFilterService" inject="formBuilderFilterService";

	 /**
	 * @question.fieldtype  formbuilderQuestion
	 * @question.item_type  matrix
	 * @formid.fieldtype    formbuilderForm
	 * @row.fieldtype       formbuilderQuestionMatrixRow
	 * @value.fieldtype     formbuilderQuestionMatrixCol
	 */
	private boolean function evaluateExpression(
		  required string question
		, required string value
		,          string formId = ( payload.formId ?: "" )
		,          string _all   = false
	) {
		var userId = payload.user.id ?: "";

		if ( !userId.len() ) {
			return false;
		}

		return formBuilderFilterService.evaluateQuestionUserLatestResponseMatch(
			  argumentCollection = arguments
			, userId             = userId
			, formId             = arguments.formId
			, submissionId       = payload.submissionId ?: ""
			, extraFilters       = prepareFilters( argumentCollection=arguments )
		);
	}

	/**
	 * @objects website_user
	 */
	private array function prepareFilters(
		  required string  question
		, required string  value
		,          string  formId             = ""
		,          boolean _all               = false
	) {
		return formBuilderFilterService.prepareFilterForUserLatestResponseMatrixAnyRowMatches( argumentCollection=arguments );
	}


}
