/**
 * @singleton false
 */
component accessors=true {

	property name="type"       type="string" default="";
	property name="reference"  type="string" default="";
	property name="level"      type="string" default="";
	property name="data"       type="struct";


	public void function pass() {
		variables.checkPasses = true;
	}
	public void function fail() {
		variables.checkPasses = false;
	}

	public boolean function passes() {
		return variables.checkPasses ?: true;
	}
	public boolean function fails() {
		return !passes();
	}

	public struct function getData() {
		return variables.data ?: {};
	}

}