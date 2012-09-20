package visitor;
import java.util.ArrayList;
import java.util.Hashtable;

public interface TableContents {
	public abstract TableContents find(String s);
	public abstract TableContents findVariables(String s);
	public abstract TableContents findFunctions(String s);
}

class GoalTable implements TableContents{
	
	String mainClass;
	Hashtable<String, ClassTable> classes = new Hashtable<String, ClassTable>(50);
    public TableContents find(String s){
    	return classes.get(s);
    }
	@Override
	public TableContents findVariables(String s) {
		// TODO Auto-generated method stub
		return null;
	}
	@Override
	public TableContents findFunctions(String s) {
		// TODO Auto-generated method stub
		return null;
	}
}

class ClassTable implements TableContents{

	boolean isMain = false;	//Is this a main class?
	boolean isExtends = false;
	String className; 			//Name of the class
	Hashtable<String, VariableTable> variables = new Hashtable<String, VariableTable>();
	Hashtable<String, FunctionTable> functions = new Hashtable<String,FunctionTable>();
	TableContents previousPointer;	//Pointer to the previous table (stack?)
	String extendsClassName;
	public TableContents find(String s){
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
	public TableContents findVariables(String s){
		VariableTable _variable = variables.get(s);
		if(_variable != null) return _variable;
		return (TableContents)previousPointer.findVariables(s);
	}
	public TableContents findFunctions(String s) {
		FunctionTable _func = functions.get(s);
		if(_func != null) return _func;
		else {
			return previousPointer.findFunctions(s);
		}
	}
}


class VariableTable implements TableContents{
	boolean isFormal = false;
	boolean isInstance = false;
	String type;
	int position;
	TableContents previousPointer;
	public TableContents find(String s){
		//return null;
		return previousPointer.find(s);
	}
	@Override
	public TableContents findVariables(String s) {
		// TODO Auto-generated method stub
		//return null;
		
		return previousPointer.findVariables(s);

	}
	@Override
	public TableContents findFunctions(String s) {
		// TODO Auto-generated method stub
		return previousPointer.findFunctions(s);
	}
	
}

class FunctionTable implements TableContents{

	Hashtable<String, VariableTable> parameters = new Hashtable<String, VariableTable>();
	ArrayList<String> orderedParameters = new ArrayList<String>();
	Hashtable<String, VariableTable> localVars = new Hashtable<String, VariableTable>();
	String returnType;					//Function's return type
	TableContents previousPointer;		//Pointer to the previous scope
	boolean isMain = false;				//Is the function inside main?
	public TableContents find(String s){
		TableContents t = localVars.get(s);
		if(t != null) return t;
		else {
			t = parameters.get(s);
			if(t != null) return t;
			else return previousPointer.find(s);
		}
	}
	@Override
	public TableContents findVariables(String s) {
		// TODO Auto-generated method stub
		TableContents t = localVars.get(s);
		if(t != null) return t;
		else {
			t = parameters.get(s);
			if(t != null) return t;
			else return previousPointer.find(s);
		}
	}
	@Override
	public TableContents findFunctions(String s) {
		// TODO Auto-generated method stub
		return previousPointer.findFunctions(s);
	}
	
}
class Gen {
	 public static void main(String[] a) {
	     System.out.println(10);
	}
	}
/*
	class A extends Gen{
	    
	    public A foo () {
	        int h;
	        B b;
	        h = new int[9][3];       
	        return b.foo();
	    }
	    
	}

	class B extends A{
	   
	    B b;
	    C c;
	    B foo;
	    public A foo() {
	        return c.foo0();
	    }
	}

	class C extends A {
	    A a;
	    public A foo0(){
	        return a; 
	    }
	}
*/