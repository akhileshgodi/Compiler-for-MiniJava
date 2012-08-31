#define ZERO() (0+0)
#define ONE() (1)
#define ZERO(a) (0+0)
#define ONE(a,b) (1)
class Test{
    public static void main(String[] a){
        System.out.println(new A().run());
    }
}
class A {
    public int run(){
        return ZERO();
    }
}
