%第一组
clc;clear all;
tic;
CNC_old=[0,0,0,0,0,0,0,0];%上一次状态，0表示CNC未在加工
CNC_current=[0,0,0,0,0,0,0,0];%当前状态
CNC_worktime=[0,0,0,0,0,0,0,0];%CNC已工作时间
CNC_worknum=[0,0,0,0,0,0,0,0];%CNC已工作次数
t_move_choice=[20,33,46];%移动i个单位所需时间
t_process_1= 560;%CNC加工完成一个一道工序的物料所需时间
t_odd=28;%RGV为CNC1#，3#，5#，7#一次上下料所需时间
t_even=31;%RGV为CNC2#，4#，6#，8#一次上下料所需时间
t_wash=25;%RGV完成一个物料的清洗作业所需时间
time_all=0;%当前已耗费时间
location_current=1;%当前位置
location_choice=[0,0,0,0];%表示某位置处的CNC是否需要上料,0表示需要上料
n=0;%执行任务次数
CNC_state=zeros(1,8);%记录当前CNC状态
delta_t=0;%每次变化的时间
k=0;
CNC_order_state=[0,0,0,0,0,0,0,0];%用于记录CNCi正处理哪个序号的物料

while(time_all<=8*60*60)
%     n=n+1;
%     CNC_state(n,:)=CNC_current;
    %检查哪些位置未在加工
    location_choice(1)=CNC_current(1)&CNC_current(2);
    location_choice(2)=CNC_current(3)&CNC_current(4);
    location_choice(3)=CNC_current(5)&CNC_current(6);
    location_choice(4)=CNC_current(7)&CNC_current(8);
    location_target=find(location_choice==0);
    %若都在工作,则等待最快完成的一个
    if(isempty(location_target))
        a=max(CNC_worktime);
        delta_t=560-a;
        time_all=time_all+delta_t;
        CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+delta_t;
        a=find(CNC_worktime>=560);
        if(~isempty(a))
        CNC_old=CNC_current;
        n=n+1;
        CNC_state(n,:)=CNC_current;
        CNC_current(find(CNC_worktime>=560))=0;
        CNC_worktime(find(CNC_worktime>=560))=0;
        end
%         CNC_old=CNC_current;
%         n=n+1;
%         CNC_state(n,:)=CNC_current;
        %重新检查哪些位置未在加工
        location_choice(1)=CNC_current(1)&CNC_current(2);
        location_choice(2)=CNC_current(3)&CNC_current(4);
        location_choice(3)=CNC_current(5)&CNC_current(6);
        location_choice(4)=CNC_current(7)&CNC_current(8);
        location_target=find(location_choice==0);
    end
    %寻找下一步位置
    m=length(location_target);
    distance=[];%清空distance
    for i=1:m
        distance(i)=abs(location_target(i)-location_current);
    end
    s=min(distance);%本次任务路程
    location_task=location_target(find(distance==s));%本次任务位置
    if(s>0)
        delta_t=t_move_choice(s);
        time_all=time_all+delta_t;%移动时间
        CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+delta_t;
        a=find(CNC_worktime>=560);%如果重置时间
        if(~isempty(a))
        CNC_old=CNC_current;
        n=n+1;
        CNC_state(n,:)=CNC_current;
        CNC_current(find(CNC_worktime>=560))=0;
        CNC_worktime(find(CNC_worktime>=560))=0;
        end
        location_current=location_task;%更新位置
    end
    %是否是第一次上料
    if((CNC_worknum(2*location_task-1)==0||(CNC_worknum(2*location_task)==0)))
        %先上奇数CNC
        if(CNC_current(2*location_task-1)==0)
            k=k+1;
            CNC_order(k)=2*location_task-1;%加工CNC编号
            CNC_order_state(CNC_order(k))=k;
            %更新总时间
            delta_t=t_odd;
            time_all=time_all+delta_t;
            %更新上料时间
            up_time(k)=time_all-delta_t;
            %更新CNC工作时间
            CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+delta_t;
            %更新CNC状态
            a=find(CNC_worktime>=560);
            if(~isempty(a))
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(find(CNC_worktime>=560))=0;
            CNC_worktime(find(CNC_worktime>=560))=0;
            end
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(2*location_task-1)=1;
            CNC_worknum(2*location_task-1)=CNC_worknum(2*location_task-1)+1;
        elseif(CNC_current(2*location_task)==0)
            k=k+1;
            CNC_order(k)=2*location_task;
            CNC_order_state(CNC_order(k))=k;
            delta_t=t_even;
            time_all=time_all+delta_t;
            %更新上料时间
            up_time(k)=time_all-delta_t;
            CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+delta_t;
            a=find(CNC_worktime>=560);
            if(~isempty(a))
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(find(CNC_worktime>=560))=0;
            CNC_worktime(find(CNC_worktime>=560))=0;
            end
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(2*location_task)=1;
            CNC_worknum(2*location_task)=CNC_worknum(2*location_task)+1;
        end
    else
        if(CNC_current(2*location_task-1)==0)
            down_time(CNC_order_state(2*location_task-1))=time_all;%确定原先在这里的序号的物料对应的下料时间
            k=k+1;
            CNC_order(k)=2*location_task-1;
            CNC_order_state(CNC_order(k))=k;
            delta_t=t_odd;
            time_all=time_all+delta_t;
            up_time(k)=time_all-delta_t;
            CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+delta_t;
            a=find(CNC_worktime>=560);
            if(~isempty(a))
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(find(CNC_worktime>=560))=0;
            CNC_worktime(find(CNC_worktime>=560))=0;
            end   
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(2*location_task-1)=1;
            CNC_worknum(2*location_task-1)=CNC_worknum(2*location_task-1)+1;

            time_all=time_all+t_wash;
            CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+t_wash;
            a=find(CNC_worktime>=560);
            if(~isempty(a))
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(find(CNC_worktime>=560))=0;
            CNC_worktime(find(CNC_worktime>=560))=0;
            end
            
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
                        
        elseif(CNC_current(2*location_task)==0)
            down_time(CNC_order_state(2*location_task))=time_all;
            k=k+1;
            CNC_order(k)=2*location_task;
            CNC_order_state(CNC_order(k))=k;
            delta_t=t_even;
            time_all=time_all+delta_t;
            up_time(k)=time_all-delta_t;
            CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+delta_t;
            a=find(CNC_worktime>=560);
            if(~isempty(a))
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(find(CNC_worktime>=560))=0;
            CNC_worktime(find(CNC_worktime>=560))=0;
            end
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(2*location_task)=1;
            CNC_worknum(2*location_task)=CNC_worknum(2*location_task)+1;
            
            time_all=time_all+t_wash;
            CNC_worktime(find(CNC_current==1))=CNC_worktime(find(CNC_current==1))+t_wash;
            a=find(CNC_worktime>=560);
            if(~isempty(a))
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;
            CNC_current(find(CNC_worktime>=560))=0;
            CNC_worktime(find(CNC_worktime>=560))=0;
            end
            
            CNC_old=CNC_current;
            n=n+1;
            CNC_state(n,:)=CNC_current;          
        end
    end
end
toc;