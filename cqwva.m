function cqwva( d,y,x,lvl,clip,mode )
% wiggle variable area plot of seismic data
%
% input
% -----
% d = matrix of data
% y = y for each sample (if y is scalar, the y = dy and is from 0:dy:(ns-1)dy)
% x = x for each trace
% lvl = 1 (default), level of gain
% clip = 3 (default), clip level
% mode = 'new'(default) open a new figure and new axis
%        'hold' plot on the current axis
%        'wipe' clear current axis and draw a new one

% input check
if ~exist('x','var')||isempty(x)
    x = 1:size(d,2);
end
if ~exist('clip','var')||isempty(clip)
    clip = 3;
end
if ~exist('y','var')||isempty(y)
    y = 1:size(d,1);
end
if ~exist('lvl','var')||isempty(lvl)
    lvl = 1;
end
if ~exist('mode','var')||isempty(mode)
    mode = 'new';
end
if strcmp(mode,'new')
    figure;
    ax =  gca;
elseif strcmp(mode,'hold')
    ax = gca;
elseif strcmp(mode,'wipe')
    cla;
    ax = gca;
else
    error('Invalid mode!');
end
if isscalar(y)
    y = 0:y:(size(d,1)-1)*y;
end

ns = size(d,1);
ntr = size(d,2);

% draw line
% normalize d
if length(x)>1
    dx = mean(diff(x));
else 
    dx = 1;
end
fct = (1/max(max(abs(d)))) * (dx*lvl);
clip = dx*clip;
dn = d*fct;
dn(dn>clip) = clip;
dn(dn<-clip) = -clip;

x = x(:)';
dn = dn + repmat(x,ns,1);
y = y(:); y = repmat([y;nan],length(x),1);
dn = [dn;ones(1,size(dn,2))*nan];
ndata = size(dn,1)*size(dn,2);
dns = reshape(dn,ndata,1);
line(dns,y,'color','k','linew',1);
axis ij;
xlim([min(x)-dx,max(x)+dx]);
ylim([min(y),max(y)]);

% fill areas
for iter = 1:size(d,2)
    nv = 1; % number of vertex
    kf = 1; % face number
    % for each trace, 
    % find samples need to be filled
    tr = dn(:,iter);
    x0 = x(iter);
    nfil = find(tr>(x0));
    if ~isempty(nfil)
        nbreak = find(diff(nfil)~=1);
        
        grp = zeros(length(nbreak)+1,2);
        grp(:,1) = [nfil(1);nfil(nbreak+1)]; % group startings
        grp(:,2) = [nfil(nbreak);nfil(end)]; % group endings
        
        face = nan*ones(size(grp,1),ns);
        vertex = nan*ones(ns,2);
        
        for k = 1:size(grp,1)
            n01 = grp(k,1);
            n02 = grp(k,2);
            n1 = n01-1; % sample above
            n2 = n02+1; % sample below
            nf = 1; % number of vertex in the current face
            if tr(n01)~=x0
                x1 = tr(n01);
                if n1~=0
                    x2 = tr(n1);
                    y2 = y(n1);
                else
                    x2 = x0;
                    y2 = y(1);
                end
                y1 = y(n01);
                vertex(nv,:) =  [x0,intercept(x0,x1,y1,x2,y2)];
                face(kf,nf) = nv;
                % go to next vertex and face
                nv = nv + 1;
                nf = nf + 1;
            end
            y12 = y(n01:n02);
            x12 = tr(n01:n02);
            vertex(nv:nv+n02-n01,:) = [x12,y12];
            face(kf,nf:nf+n02-n01) = nv:nv+n02-n01;
            nv = nv + n02 - n01 + 1;
            nf = nf + n02 - n01 + 1;
            if tr(n02)~=x0
                x1 = tr(n02);
                if n2~=(nfil(end)+1)
                    x2 = tr(n2);
                    y2 = y(n2);
                else
                    x2 = x0;
                    y2 = y(end-1);
                end
                y1 = y(n02);
                vertex(nv,:) =  [x0,intercept(x0,x1,y1,x2,y2)];
                face(kf,nf) = nv;
                % go to next vertex and face
                nv = nv + 1;
            end
            kf = kf + 1;
        end
        % add the first face
        patch('faces',face(1:kf-1,:),'vertices',vertex(1:nv-1,:),'facecolor','k','edgecolor','none');
        drawnow;
    end
end





end

function y = intercept(x,x1,y1,x2,y2)
    y = (y2-y1)/(x2-x1)*(x-x1) + y1;
end