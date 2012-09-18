
#define ZERO() (0)
#define y() (a)
#define print(x) { x=3; System.out.println(x);}

class Test{
    public static void main(String[] a){
        System.out.println(1);    
    }
}
class A {
    public int run(){
        int x;
        print(y());
        return 1;
    }
}
