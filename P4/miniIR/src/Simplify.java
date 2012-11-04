import syntaxtree.*;
import visitor.*;

public class Simplify {
   public static void main(String [] args) {
	  try {
         Node root = new MiniJavaParser(System.in).Goal();
         //System.out.println("Program parsed successfully");
         SymbolTable s;
         s = (SymbolTable)root.accept(new SymbolTableVisitor()); // Your assignment part is invoked here.
         s = (SymbolTable)root.accept(new GJNoArguDepthFirst(s));
         root.accept(new MiniIRBuilder(s));
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
} 
