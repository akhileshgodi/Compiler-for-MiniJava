package visitor;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Vector;

public interface SymbolTable {
	public abstract SymbolTable find(String s);
	public abstract SymbolTable findVariables(String s);
	public abstract SymbolTable findFunctions(String s);
}

class GoalTable implements SymbolTable{
	String mainClass;
	Hashtable<String, ClassTable> classes = new Hashtable<String, ClassTable>();
    public SymbolTable find(String s){
    	return classes.get(s);
    }
	@Override
	public SymbolTable findVariables(String s) {
		// TODO Auto-generated method stub
		return null;
	}
	@Override
	public SymbolTable findFunctions(String s) {
		// TODO Auto-generated method stub
		return null;
	}
}

class ClassTable implements SymbolTable{

	boolean isMain = false;	//Is this a main class?
	boolean isExtends = false;
	String className; 			//Name of the class
	Hashtable<String, VariableTable> variables = new Hashtable<String, VariableTable>();
	Hashtable<String, FunctionTable> functions = new Hashtable<String,FunctionTable>();
	Vector<VariableTable> allVariables = new Vector<VariableTable>();
	Vector<FunctionTable> allFunctions = new Vector<FunctionTable>();
	Vector<VariableTable> itsVariables = new Vector<VariableTable>();
	SymbolTable previousPointer;	//Pointer to the previous table (stack?)
	String extendsClassName;
	
	//Added later :
	int globalOffset;
	int methodOffset;
	/* The above were added for MiniIR*/
	public SymbolTable find(String s){
		VariableTable _variable = variables.get(s);
		if(_variable != null) return _variable;
		else {
			FunctionTable _func = functions.get(s);
			if(_func != null) return _func;
			else {
				return previousPointer.find(s);
			}
		}
		
	}
	public SymbolTable findVariables(String s){
		VariableTable _variable = variables.get(s);
		if(_variable != null) return _variable;
		return (SymbolTable)previousPointer.findVariables(s);
	}
	public SymbolTable findFunctions(String s) {
		FunctionTable _func = functions.get(s);
		if(_func != null) return _func;
		else {
			return previousPointer.findFunctions(s);
		}
	}
}


class VariableTable implements SymbolTable{
	boolean isFormal = false;
	boolean isInstance = false;
	String type;
	int position;
	SymbolTable previousPointer;
	public SymbolTable find(String s){
		//return null;
		return previousPointer.find(s);
	}
	@Override
	public SymbolTable findVariables(String s) {
		// TODO Auto-generated method stub
		//return null;
		
		return previousPointer.findVariables(s);

	}
	@Override
	public SymbolTable findFunctions(String s) {
		// TODO Auto-generated method stub
		return previousPointer.findFunctions(s);
	}
	
}

class FunctionTable implements SymbolTable{

	Hashtable<String, VariableTable> parameters = new Hashtable<String, VariableTable>();
	ArrayList<String> orderedParameters = new ArrayList<String>();
	Hashtable<String, VariableTable> localVars = new Hashtable<String, VariableTable>();
	String funcName;
	String returnType;					//Function's return type
	SymbolTable previousPointer;		//Pointer to the previous scope
	int position;
	boolean isMain = false;				//Is the function inside main?
	public SymbolTable find(String s){
		SymbolTable t = localVars.get(s);
		if(t != null) return t;
		else {
			t = parameters.get(s);
			if(t != null) return t;
			else return previousPointer.find(s);
		}
	}
	@Override
	public SymbolTable findVariables(String s) {
		// TODO Auto-generated method stub
		SymbolTable t = localVars.get(s);
		if(t != null) return t;
		else {
			t = parameters.get(s);
			if(t != null) return t;
			else return previousPointer.find(s);
		}
	}
	@Override
	public SymbolTable findFunctions(String s) {
		// TODO Auto-generated method stub
		return previousPointer.findFunctions(s);
	}
	
}
