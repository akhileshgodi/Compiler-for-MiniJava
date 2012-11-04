package dataStructures;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Vector;

/**
 * @author Akhilesh Godi (CS10B037)
 *
 */
public class ControlFlowGraph {

	public ArrayList<StatementNode> blocks;
	public HashMap<Integer,Integer> startPoints;
	public HashMap<Integer, Integer> endPoints;
	public int itsParamsSize;
	public int maxParams;
	public int maxParamsOnStack;
	public int noOfCalleeSaveRegisters;
	public int totalNoOfSpilledArgs;
	public int maxCallerSaveRegisters;
	public Vector<Integer> toStoreAndLoadCalleeSaveRegisters;
	public ControlFlowGraph(){
		blocks = new ArrayList<StatementNode>();
		startPoints = new HashMap<Integer, Integer>();
		endPoints = new HashMap<Integer, Integer>();
		maxParams = 0;
		itsParamsSize = 0;
		noOfCalleeSaveRegisters = 0;
		totalNoOfSpilledArgs = 0;
		maxCallerSaveRegisters = 0;
		maxParamsOnStack = 0;
		toStoreAndLoadCalleeSaveRegisters = new Vector<Integer>();
	}
	
	
	/**
	 * @return the blocks
	 */
	public ArrayList<StatementNode> getBlocks() {
		return blocks;
	}

	/**
	 * @param blocks the blocks to set
	 */
	public void setBlocks(ArrayList<StatementNode> blocks) {
		this.blocks = blocks;
	}
	
	public void insertBlock(StatementNode block){
		this.blocks.add(block);
	}

	/**
	 * @param instructionNumber
	 * @return
	 */
	public StatementNode getStatement(int instructionNumber) {
		// TODO Auto-generated method stub
		return this.blocks.get(instructionNumber);
		
	}
	
	/*-----For debugging only!-----*/
	public void printGraph(){
		
		for(int i = 0; i < blocks.size(); i++){
			System.out.printf("Block " + i + ": ");
			String type = null;
			switch(blocks.get(i).getType()){
				case -1:type = "WHAT?";break; 
				case 0:type = "NOOP";break;
				case 1:type = "ERROR";break;
				case 2:type = "CJUMP";break;
				case 3:type = "JUMP";break;
				case 4:type = "HSTORE";break;
				case 5:type = "HLOAD";break;
				case 6:type = "MOVE";break;
				case 7:type = "PRINT";break;
				case 8:type = "RETURN";break;
				default:System.out.println("Flow graph instruction type error");break;
			}
			System.out.printf(type + "{ def : ");
			System.out.print(blocks.get(i).getDef() + "} { use :");
			System.out.print(blocks.get(i).getUse() + "} { in :");
			System.out.print(blocks.get(i).getLiveIn() + "} { out : ");
			System.out.print(blocks.get(i).getLiveOut() + " } ");
			System.out.print("{ Successors : " + blocks.get(i).getSuccessors() + "} " );
			System.out.println("Call Stack Size : { "+ blocks.get(i).callStackSize + " }");
		}
			
	}
	
}
