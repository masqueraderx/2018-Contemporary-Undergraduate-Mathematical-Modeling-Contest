%第三组
clc;clear all;
tic;
t_move_choice=[0,18,32,46];%移动i个单位所需时间
t_odd=27;%RGV为CNC1#，3#，5#，7#一次上下料所需时间
t_even=32;%RGV为CNC2#，4#，6#，8#一次上下料所需时间
t_wash=25;%RGV完成一个物料的清洗作业所需时间
iter=0;%搜索次数

while(iter<5000)
 %%
    CNC_num_1=[]; CNC_num_2=[];    down_1st=[]; down_2nd=[];    up_1st=[];  up_2nd=[];    location_all=[];
	CNC_order_state_1=[0,0,0,0,0];%用于记录CNCi正处理哪个序号的物料
    CNC_order_state_2=[0,0,0];%用于记录CNCi正处理哪个序号的物料
    CNC_1=[0,0,0,0,0];%0表示CNC未在加工,第一道工序CNC
    CNC_2=[0,0,0];%0表示CNC未在加工，第二道工序CNC
    CNC_worktime_1=[0,0,0,0,0];%第一道工序CNC已加工时间
    CNC_worktime_2=[0,0,0];
    t_delta=0;
    time_all=0;
    location_current=1;%初始位置
    n=0;
    n2=0;
    n3=0;
    
    %选取4个为第二工序
    CNC_procedure=ones(1,8);
    m=zeros(1,3);
    for i=1:3
        while(1)
            a=rem(round(rand()*10),8)+1;
            if(~ismember(a,m))
                m(i)=a;
                break;
            end
        end
        CNC_procedure(m(i))=2;%i表示CNCi为第几道工序
    end
    
    record_1=find(CNC_procedure==1); %记录某台CNC是第几个做第一道工序的
    record_2=find(CNC_procedure==2); %记录某台CNC是第几个做第二道工序的
    
    %根据工序确定其上下料时间
    s=0;t=0;
    for i=1:8
        if(CNC_procedure(i)==1)
            s=s+1;
            if(mod(i,2))
                t_1st_uAndD(s)=t_odd;%第一道工序CNC上料时间
            else
                t_1st_uAndD(s)=t_even;
            end
        else
            t=t+1;
            if(mod(i,2))
                t_2nd_uAndD(t)=t_odd;
            else
                t_2nd_uAndD(t)=t_even;
            end            
        end
    end
      
    while(time_all<=8*3600)
%%
%第一道工序
        n=n+1;
        location_all(n,1)=location_current;%记录任务n工序1RGV运动位置
        task_procedure(n)=1;%任务n处于第一道工序
        %先去CNC_1上料，若都在工作,则等待最快完成的一个
        while(isempty(find(CNC_1==0)))
            a=max(CNC_worktime_1);
            t_delta=455-a;
            
            time_all=time_all+t_delta;
            
            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%更新其他正加工的CNC_1的已加工时间
            CNC_1(find(CNC_worktime_1>=455))=0;%加工完CNC置0
            CNC_worktime_1(find(CNC_worktime_1>=455))=0;%加工完CNC计时置0
            
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%更新其他正加工的CNC_2的已加工时间
            CNC_2(find(CNC_worktime_2>=182))=0;%加工完CNC置0
            CNC_worktime_2(find(CNC_worktime_2>=182))=0;%加工完CNC计时置0
        end
        
        while(1)%以概率搜索已完成的CNC_1
            num=rem(round(rand()*10),8)+1;%取一个随机编号变异

            while(~ismember(num,record_1)||CNC_1(find(record_1==num))==1||CNC_procedure(num)==2)%当前任务为新任务，则去第一道工序CNC处，且该处并未在加工
                num=rem(round(rand()*10),8)+1;%取一个随机编号变异
            end
            
            s=abs(location_current-ceil(num/2));%与目标CNC的距离
            if(s==0)
                break;
            end
            if(s==1)
                if(rand()<1/2)
%                 if(rand()<0.6)
                    break;
                end
            end
            if(s==2)
                if(rand()<1/3)
%                 if(rand()<0.3)
                    break;
                end
            end
            if(s==3)
                if(rand()<1/6)
%                 if(rand()<0.1)
                    break;
                end
            end
        end
        
        t_delta=t_1st_uAndD(find(record_1==num));
                             
        time_all=time_all+t_move_choice(s+1)+t_delta;
        location_current=ceil(num/2);%更新当前位置
        
        CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC_1的已加工时间           
        CNC_1(find(CNC_worktime_1>=455))=0;%加工完CNC置0
        CNC_worktime_1(find(CNC_worktime_1>=455))=0;%加工完CNC计时置0
        
        CNC_1(find(record_1==num))=1;%更新CNC_1状态
        
        CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC_2的已加工时间
        CNC_2(find(CNC_worktime_2>=182))=0;%加工完CNC置0
        CNC_worktime_2(find(CNC_worktime_2>=182))=0;%加工完CNC计时置0
        
        up_1st(n+1)=time_all-t_delta;%记录任务n+1工序1上料时间
        if(CNC_order_state_1(find(record_1==num))~=0)
            n2=CNC_order_state_1(find(record_1==num));%当前要下料的物料的序号，即确认正要做第二道工序的物料的序号
            down_1st(n2)=time_all-t_delta;%记录任务n2工序1下料时间
        end
        
        CNC_num_1(n)=num;%记录任务n的工序1CNC编号
        CNC_order_state_1(find(record_1==num))=n;%记录当前CNC_1正在做第n个物料
 %%
 %第二道工序
         if(n2~=0)
            location_all(n2,2)=location_current;%记录任务n工序2RGV运动位置
            task_procedure(n2)=2;%任务n处于第二道工序

            %去CNC_2上料，若都在工作,则等待最快完成的一个
            while(isempty(find(CNC_2==0)))
                a=max(CNC_worktime_2);
                t_delta=182-a;

                time_all=time_all+t_delta;

                CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%更新其他正加工的CNC_2的已加工时间
                CNC_2(find(CNC_worktime_2>=182))=0;%加工完CNC置0
                CNC_worktime_2(find(CNC_worktime_2>=182))=0;%加工完CNC计时置0

                CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%更新其他正加工的CNC_1的已加工时间
                CNC_1(find(CNC_worktime_1>=455))=0;%加工完CNC置0
                CNC_worktime_1(find(CNC_worktime_1>=455))=0;%加工完CNC计时置0
            end

            while(1)%以概率搜索已完成的CNC_2
                num=rem(round(rand()*10),8)+1;%取一个随机编号变异

                while(~ismember(num,record_2)||CNC_2(find(record_2==num))==1||CNC_procedure(num)==1)%当前任务需要去第二道工序CNC处，且该处并未在加工
                    num=rem(round(rand()*10),8)+1;%取一个随机编号变异
                end

                s=abs(location_current-ceil(num/2));%与目标CNC的距离
                if(s==0)
                    break;
                end
                if(s==1)
                    if(rand()<1/2)
    %                 if(rand()<0.6)
                        break;
                    end
                end
                if(s==2)
                    if(rand()<1/3)
    %                 if(rand()<0.3)
                        break;
                    end
                end
                if(s==3)
                    if(rand()<1/6)
    %                 if(rand()<0.1)
                        break;
                    end
                end
            end

            t_delta=t_2nd_uAndD(find(record_2==num));

            time_all=time_all+t_move_choice(s+1)+t_delta;
            location_current=ceil(num/2);%更新当前位置

            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC_2的已加工时间           
            CNC_2(find(CNC_worktime_2>=182))=0;%加工完CNC置0
            CNC_worktime_2(find(CNC_worktime_2>=182))=0;%加工完CNC计时置0

            CNC_2(find(record_2==num))=1;%更新CNC_2状态

            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC_1的已加工时间
            CNC_1(find(CNC_worktime_1>=455))=0;%加工完CNC置0
            CNC_worktime_1(find(CNC_worktime_1>=455))=0;%加工完CNC计时置0

            time_all=time_all+t_wash;
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_wash;%更新其他正加工的CNC_2的已加工时间
            CNC_2(find(CNC_worktime_2>=182))=0;%加工完CNC置0
            CNC_worktime_2(find(CNC_worktime_2>=182))=0;%加工完CNC计时置0

            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_wash;%更新其他正加工的CNC_1的已加工时间
            CNC_1(find(CNC_worktime_1>=455))=0;%加工完CNC置0
            CNC_worktime_1(find(CNC_worktime_1>=455))=0;%加工完CNC计时置0        

            up_2nd(n2)=time_all-t_delta-t_wash;%记录任务n2工序2上料时间
            if(CNC_order_state_2(find(record_2==num))~=0)
                n3=CNC_order_state_2(find(record_2==num));%当前要下料的物料的序号，即确认已完成第二道工序等待清洗的物料的序号
                down_2nd(n3)=time_all-t_delta-t_wash;%记录任务n3工序2下料时间
            end

            CNC_num_2(n2)=num;%记录任务n2的工序2CNC编号
            CNC_order_state_2(find(record_2==num))=n2;%记录当前CNC_2正在做第n2个物料  
         end
    end
    iter=iter+1;
    location_save{iter}=location_all(1,:);%保存每一次的路径
    down_1st_save{iter}=down_1st(1,:);%保存每一次的第一道工序下料时间
    up_1st_save{iter}=up_1st(1,:);%保存每一次的第一道工序上料时间
    down_2nd_save{iter}=down_2nd(1,:);%保存每一次的第二道工序下料时间
    up_2nd_save{iter}=up_2nd(1,:);%保存每一次的第二道工序上料时间
    CNC_num_1_save{iter}=CNC_num_1(1,:);%保存每一次的工序1CNC加工编号序列
    CNC_num_2_save{iter}=CNC_num_2(1,:);%保存每一次的工序2CNC加工编号序列
    task_num(iter,:)=n;%保存每一次的完成物料数
end
max(task_num)
find(task_num==max(task_num))
toc;