---
title: python装饰器函数式编程
date: 2017-09-24 13:52:36
tags: python
---

# 函数式编程
> 函数式编程（英语：functional programming）或称函数程序设计,又称泛函编程,是一种编程典范,它将电脑运算视为数学上的函数计算,并且避免使用程序状态以及易变对象,函数编程语言最重要的基础是λ演算（lambda calculus,而且λ演算的函数可以接受函数当作输入（引数）和输出（传出值）

函数式编程范式相对命令式编程(Imperative programming),函数式编程更加强调程序执行的结果而非执行的过程,倡导利用若干简单的执行单元让计算结果不断渐进,逐层推导复杂的运算,而不是设计一个复杂的执行过程.而命令式编程使用各种变量以及复杂的控制语句来编写逻辑代码,最初图灵机的设计就是属于命令式编程,在纸带上面刻各种孔,然后机器根据纸带上的孔执行各种命令.C/C++ Java Python等各种面向对象编程其实都属于命令式编程范围,虽然现在这些高级语言或多或少都已经支持Lambda表达式以开始支持函数式编程,但是相比Lisp Haskell Clojure等这些纯正函数式语言,Python在函数式编程方面支持的相对少一点.

## Python Lambda

> λ演算（英语：lambda calculus，λ-calculus）是一套从数学逻辑中发展，以变量绑定和替换的规则，来研究函数如何抽象化定义、函数如何被应用以及递归的形式系统。它由数学家阿隆佐·邱奇在20世纪30年代首次发表。Lambda演算作为一种广泛用途的计算模型，可以清晰地定义什么是一个可计算函数，而任何可计算函数都能以这种形式表达和求值，它能模拟单一磁带图灵机的计算过程；尽管如此，Lambda演算强调的是变换规则的运用，而非实现它们的具体机器。

说到Python支持函数式编程必须得说道Lambda表达式,Lambda按照wiki上说法比较复杂,其实简单的说Lambda表达式就是匿名函数

```
    lambda argument: manipulate(argument)
```    

```
    squares = map(lambda x: x * x, range(9))
    print squares

```
```
    number_list = range(-5, 5)
    less_than_zero = list(filter(lambda x: x < 0, number_list))
    print(less_than_zero)
```

```
    number_list = range(-5, 5)
    less_than_zero = list(filter(lambda x: x < 0, number_list))
    print(less_than_zero)
```

上面三个代码片段就是map/reduce/filter和lambda表达式结合的一个例子,python在支持lambda时,为了不让开发者乱用这个特性,lambda设计的比较简单,就是在lamba后面加函数以及操作,只要使用得当lambda可以让代码看起来更加简洁优雅,但是如果使用不当代码可读性会很差

## 函数式编程特性

其实对于纯正的函数式编程,我接触的比较少,像lisp Haskell Scheme以及更兴起的Clojure都不是很了解,下次可以好好的学习下Clojure
函数式编程主要有三大特性:
- immutable data 不可变数据: 不像命令式编程那样数据都是有状态的,函数式编程中采用无状态数据,像Clojure中变量是不可变的
- first class functions: 函数和变量一样使用,只要变量有的特性函数都有
- 尾递归优化: 使用尾递归优化技术——每次递归时都会重用stack,这样一来能够提升性能,Python就不支持

函数式编程的几个技术:
- map & reduce: python中有这两个函数
- pipeline: 这个技术的意思是，把函数实例成一个一个的action，然后，把一组action放到一个数组或是列表中，然后把数据传给这个action list，数据就像一个pipeline一样顺序地被各个函数所操作，最终得到我们想要的结果
- recursing 递归: 递归最大的好处就简化代码，他可以把一个复杂的问题用很简单的代码描述出来。注意：递归的精髓是描述问题，而这正是函数式编程的精髓
- currying：把一个函数的多个参数分解成多个函数， 然后把函数多层封装起来，每层函数都返回一个函数去接收下一个参数这样,可以简化函数的多个参数
- higher order function 高阶函数：所谓高阶函数就是函数当参数，把传入的函数做一个封装，然后返回这个封装函数。现象上就是函数传进传出，就像面向对象对象满天飞一样

---

# 函数装饰器

python中的函数也是一个对象,可以用来传递,例如:

```
def foo():
    print("foo")

def bar(func):
    func()

bar(foo)
```

> 装饰器本质上是一个 Python 函数或类，它可以让其他函数或类在不需要做任何代码修改的前提下增加额外功能，装饰器的返回值也是一个函数/类对象。它经常用于有切面需求的场景，比如：插入日志、性能测试、事务处理、缓存、权限校验等场景，装饰器是解决这类问题的绝佳设计。有了装饰器，我们就可以抽离出大量与函数功能本身无关的雷同代码到装饰器中并继续重用。概括的讲，装饰器的作用就是为已经存在的对象添加额外的功能

说到装饰器,网上举的例子大部分都是关于日志打印的,这个确实很经典,简单的说就是想要在一个已经定义好的函数中打印一些日志,需要自己再封装一个函数,然后在该函数中再调用,但是采用这种方法的话会破坏原先代码的逻辑,于是装饰器方案诞生了:

```
def use_logging(func):

    def wrapper():
        logging.warn("%s is running" % func.__name__)
        return func()
    return wrapper      #返回函数

def foo():
    print('i am foo')

foo = use_logging(foo)  #函数作为参数传递
foo()                   #还是调用foo() 没有破坏原程序逻辑 调用foo()可以打印日志信息还执行了原代码 
```

python中对装饰器的支持采用@这个符号,这个是个语法糖,把@放在use_logging函数定义的开头,相当于foo = use_logging(foo), 只需要在foo()函数的开头加上@use_logging即可在不改变原函数逻辑的情况实现日志打印ongn     
```
def use_logging(func):

    def wrapper():
        logging.warn("%s is running" % func.__name__)
        return func()
    return wrapper

@use_logging
def foo():
    print("i am foo")

foo()
```

如果foo()函数需要传参,*args/**kargs 利用这这两个参数可以传类似多个参数或者关键字参数,这个时候use_logging(func)中的内部函数可以更改为:
```
    def wrapper(*args, **kargs):
        logging.warn("%s is running" % func.__name__)
        return func(*args, **kargs)
    return wrapper 
```

装饰器的使用非常灵活,例如还可以定义带参数的装饰器.拿上面日志的例子来说,如果日志打印需要打印不同的等级信息,那么use_logging参数需要有一个日志等级参数.
```
    def use_logging(level):
        def decorator(func):
            def wrapper(*args, **kwargs):
                if level == "warn":
                    logging.warn("%s is running" % func.__name__)
                elif level == "info":
                    logging.info("%s is running" % func.__name__)
                return func(*args)
            return wrapper

    return decorator

    @use_logging(level="warn")
    def foo(name='foo'):
        print("i am %s" % name)

    foo()
```

use_logging函数定义看起来有点绕, @use_logging(level="warn") 会被python解析为foo = use_logging(level)(foo) 这样的话use_logging(level)需要返回一个装饰器, 也就不难理解上面的那段代码了

---
# 类装饰器

装饰器也可用来装饰类,此时被修饰的函数会调用类的__call__方法
```
class Foo(object):
    def __init__(self, func):
        print "sinit in Foo"
        self._func = func

    def __call__(self):
        print ('class decorator runing')
        self._func()
        print ('class decorator ending')

@Foo
def bar():
    print ('bar')

bar()
```
上面代码执行完毕后会打印:
```
init in Foo
class decorator runing
bar
class decorator ending
```
Foo函数定义了两个函数:
1. 一个是__init__()，这个方法是在我们给某个函数decorator时被调用，所以，需要有一个fn的参数，也就是被decorator的函数
2. 一个是__call__()，这个方法是在我们调用被decorator函数时被调用的

# 装饰器副作用
decorator函数中原函数的信息被破坏了 例如__name__ docstring 参数列表等, 不过functools.wraps可以解决这个问题
```
    def use_logging(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if level == "warn":
                logging.warn("%s is running" % func.__name__)
            elif level == "info":
                logging.info("%s is running" % func.__name__)
            return func(*args)
        return wrapper
```