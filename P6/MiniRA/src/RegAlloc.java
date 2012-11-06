import java.util.HashMap;

import dataStructures.ControlFlowGraph;
import syntaxtree.*;
import visitor.*;

public class RegAlloc {

	public static void main(String [] args) {
      try {
    	
    	 Node root = new microIRParser(System.in).Goal();
         //System.out.println("Program parsed successfully");
         //root.accept(new GJNoArguDepthFirst()); // Your assignment part is invoked here.
         HashMap<String, ControlFlowGraph> CFGS = (HashMap<String, ControlFlowGraph>)root.accept(new LivenessAnalysis()); // Your assignment part is invoked here.
         root.accept(new LinearScan(CFGS));
         //GJVisitor<Node, Object> v =  new AnalysisVisitor();
         //root.accept(v, null); // Your assignment part is invoked here.
         
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
} 

