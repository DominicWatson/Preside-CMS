/**
 * @expressionContexts  webrequest
 * @expressionCategory  formbuilder
 * @expressionTags      formbuilderV2Form
 */
component {

	property name="formBuilderFilterService" inject="formBuilderFilterService";

	/**
	 * @question.fieldtype formbuilderQuestion
	 * @question.item_type number
	 */
	private boolean function evaluateExpression(
		  required string  question
		, required numeric value
		,          string  _numericOperator = "eq"
	) {
		return formBuilderFilterService.evaluateQuestionSubmissionResponseMatch(
			  argumentCollection = arguments
			, userId             = payload.user.id                            ?: ""
			, formId             = payload.formbuilderSubmission.formId       ?: ""
			, submissionId       = payload.formbuilderSubmission.submissionId ?: ""
			, extraFilters       = prepareFilters( argumentCollection=arguments )
		);
	}

	/**
	 * @objects formbuilder_formsubmission
	 */
	private array function prepareFilters(
		  required string question
		, required string value
		,          string _numericOperator = "eq"
	) {
		return formBuilderFilterService.prepareFilterForSubmissionQuestionResponseMatchesNumber( argumentCollection=arguments );
	}

}
