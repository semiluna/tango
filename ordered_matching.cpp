#include "mex.hpp"
#include "mexAdapter.hpp"

#include <vector>
#include <utility>

#define INF (0x3f3f3f3f)

using namespace std;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
public:
    void operator() (ArgumentList outputs, ArgumentList inputs) {
        const int nrMissions = inputs[ 0 ][ 0 ];
        const int nodes = inputs[ 1 ][ 0 ];
        const int flight_time = inputs[ 2 ][ 0 ];
        
        vector <pair<int, int>> missions;
        
        for (int i = 0; i < nrMissions; i++) {
            int x = inputs[ 3 ][ i ][ 0 ];
            int y = inputs[ 3 ][ i ][ 1 ];
            
            missions.push_back({ x, y });
        }
        
        vector<vector<int>> dist(nodes, vector<int>(nodes));
        for (int i = 0; i < nodes; i++) {
            for (int j = 0; j < nodes; j++) {
                dist[ i ][ j ] = inputs[ 4 ][ i ][ j ];
            }
        }
        
        vector <int> gcDistance;
        for (int i = 0; i < nodes; i++)
            gcDistance.push_back(inputs[ 5 ][ i ]);
        
        vector <vector<int>> sol = ordered_matching(missions, dist, gcDistance, flight_time);
        
        matlab::data::ArrayFactory factory;
        for (int i = 0; i < sol.size(); i++) {
            outputs[ i ] = factory.createArray<int32_t> ({1, sol[ i ].size()}, sol[ i ].data(), sol[ i ].data() + sol[ i ].size());
        }
    }
    
    vector<vector<int>> ordered_matching(vector<pair<int, int>> &missions, vector<vector<int>> &dist, vector<int> &gcDistance, int maxFlightTime) {
      vector<vector<int>> part;

      int idx = 0, crtTime, totalTime = 0;
      vector <int> crt;

      int firstPickup = missions[idx].first;
      int firstDelivery = missions[idx].second;

      crtTime = gcDistance[firstPickup] + dist[firstPickup][firstDelivery] + gcDistance[firstDelivery];
      crt.push_back(idx);
      idx++;
      while (idx < missions.size()) {
        int lastDelivery = missions[idx-1].second;
        int pickup = missions[idx].first;
        int delivery = missions[idx].second;

        int newTime = crtTime - gcDistance[lastDelivery] + dist[lastDelivery][pickup] + dist[pickup][delivery] + gcDistance[delivery];
        if (newTime <= maxFlightTime) {
          crtTime = newTime;
          crt.push_back(idx);
        } else {
          part.push_back(crt);
          crt.clear();
          totalTime += crtTime;

          crtTime = gcDistance[pickup] + dist[pickup][delivery] + gcDistance[delivery];
          crt.push_back(idx);
        }

        idx++;
      }

      totalTime += crtTime;
      part.push_back(crt);

      return part;
    }

};