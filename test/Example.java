/*
 * Copyright 2025 Google Java Format Plugin Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// 测试Java文件 - 用于验证Google Java Format插件
public class Example{
private String name;
private int age;

public Example(String name,int age){
this.name=name;
this.age=age;
}

public void printInfo(){
if(name!=null&&age>0){
System.out.println("Name: "+name+", Age: "+age);
}else{
System.out.println("Invalid data");
}
}

public static void main(String[]args){
Example example=new Example("测试用户",25);
example.printInfo();

// 测试不同的代码风格
for(int i=0;i<5;i++){
System.out.println("Number: "+i);
}

if(args.length>0){
System.out.println("Arguments provided: "+args.length);
}else{
System.out.println("No arguments");
}
}
}
