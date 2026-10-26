// One invocation per camera/family, not per vertex. Preserve exact homogeneous
// previous positions until Pcurrent * inverse(Pprevious) removes camera motion.
cbuffer Current : register(b0) { float4 current_view[4]; }
cbuffer Previous : register(b1) { float4 previous_view[4]; }
cbuffer CurrentFrame : register(b2) { float4 current_frame[16]; }
cbuffer PreviousFrame : register(b3) { float4 previous_frame[16]; }
RWStructuredBuffer<float4> Transform : register(u0);
[numthreads(1,1,1)]
void main() {
  float4 rows[4], inverse_rows[4];
  [unroll] for (uint i=0;i<4;++i) {
    rows[i]=previous_view[i];
    inverse_rows[i]=float4(i==0,i==1,i==2,i==3);
  }
  bool valid=true;
  [unroll] for (uint c=0;c<4;++c) {
    uint pivot=c;
    [unroll] for (uint r=c+1;r<4;++r) if(abs(rows[r][c])>abs(rows[pivot][c])) pivot=r;
    float4 temp=rows[c]; rows[c]=rows[pivot]; rows[pivot]=temp;
    temp=inverse_rows[c]; inverse_rows[c]=inverse_rows[pivot]; inverse_rows[pivot]=temp;
    valid = valid && abs(rows[c][c])>1e-12f && all(isfinite(rows[c]));
    float divisor=abs(rows[c][c])>1e-12f ? rows[c][c] : 1.f;
    rows[c]/=divisor; inverse_rows[c]/=divisor;
    [unroll] for(uint r=0;r<4;++r) if(r!=c) {
      float factor=rows[r][c]; rows[r]-=factor*rows[c]; inverse_rows[r]-=factor*inverse_rows[c];
    }
  }
  float4 current_rows[4];
  [unroll] for(uint r=0;r<4;++r) {
    float4 v=current_view[r];
    if(r<2) v-=current_frame[15][r]*current_view[3];
    current_rows[r]=v.x*inverse_rows[0]+v.y*inverse_rows[1]+v.z*inverse_rows[2]+v.w*inverse_rows[3];
    // The interpolated previous clip has already had jitter removed.
    current_rows[r].w+=dot(current_rows[r].xy,previous_frame[15].xy);
    Transform[r]=valid ? current_rows[r] : 0.f;
  }
}
